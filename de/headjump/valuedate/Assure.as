package de.headjump.valuedate {
	import de.headjump.tests.TestValuedate;
	
	public class Assure {
		public static const VERSION:Number = 0.91;
		private var _func:Function;
		private var _is_optional:Boolean;
		private var _prepare_value:Function;
		
		public static function get value():Assure {
			return new Assure();
		}		
		// alias
		public static function get v():Assure { return value; }
		
		public static function get optional_value():Assure {
			return new Assure(true);
		}		
		// alias
		public static function get optional():Assure { return optional_value; }
		public static function get o():Assure { return optional_value; }
		
		public function Assure(is_optional_value:Boolean = false) {
			_is_optional = is_optional_value;
			_func = null;
			_prepare_value = null;
		}
		
		protected function check(func:Function, prepare_value_function:Function = null):Assure {
			var old:Function = _func;
			_func = function(value:*):void {
				if (old != null) old.apply(null, [value]);
				
				var val:*;
				if (_prepare_value != null) {
					val = _prepare_value.apply(null, [value]);
				} else {
					val = value;
				}
				
				func.apply(null, [val]);
				
				if (prepare_value_function != null) {
					_prepare_value = prepare_value_function;
				}
			}
			return this;
		}
		
		public function isA(c:Class):Assure {
			return check(function(value:*):void {
				if (!(value is c)) throw new Error("!ofClass " + [value, c]);
			});
		}
		
		public function forEach(a:Assure):Assure {
			return check(function(value:*):void {
				for each (var c:* in value) {
					if (!a.validate(c)) throw new Error("!forEach " + [value, c, a]);
				}
			});
		}
		
		public function equalsOneOf(...params):Assure {
			// value equals ONE of params
			return check(function(value:*):void {
				for each(var p:* in params) {
					if (value === p) return;
				}
				throw new Error("!equals " + [value, params])
			});
		}
		
		/**
		 * assures value neither null nor undefined
		 */
		public function notNull():Assure {
			return check(function(value:*):void {
				if (value == null || value == undefined) throw new Error("!NotNull -> " + value);
			});
		}
		
		public function oneOf(... assures):Assure {
			return check(function(value:*):void {
				for each(var a:Assure in assures) {
					if (a.validate(value)) return;
				}
				throw new Error("!oneOf " + value + " - " + assures);
			});
		}
		
		public function get assure_function():Function {
			return _func;
		}
		
		public function assures(predefined_assure:Assure):Assure {
			// queue in a predefined assure e.g 
			// 		Assure.value.isA(Number).assures(my_predefined_assure).validate(10);
			return check(predefined_assure.assure_function);
		}
		
		public function not(a:Assure):Assure {
			return check(function(value:*):void {
				if(a.validate(value)) throw new Error("!not " + value + " - " + a);
			});
		}
		
		public function inRange(min:Number, max:Number):Assure {
			return check(function(value:*):void {
				if (!(value is Number)) throw new Error("!inRange value not a Number " + [value]);
				if (value < min) throw new Error("!inRange smaller min " + [value, min]);
				if (value > max) throw new Error("!inRange greater max " + [value, max]);
			});
		}
		
		public function trueFor(func:Function):Assure {
			return check(function(value:*):void {
				if (!func.apply(null, [value])) throw new Error("!trueFor " + func);
			});
		}
		
		public function notEquals(val:*):Assure {
			return check(Assure.v.notEqualsOneOf(val).assure_function);
		}
		
		public function equals(val:*):Assure {
			return check(Assure.v.equalsOneOf(val).assure_function);
		}
		
		public function notEqualsOneOf(...params):Assure {
			// value equals NONE of params
			return check(function(value:*):void {
				for each(var p:* in params) {
					if (value ===p) throw new Error("!NOTequals " + [value, p, params]);
				}
			});
		}
		
		public function asInt():Assure {
			return check(function(value:*):void {
				var testint:Number = parseInt("" + value);
				if (isNaN(testint)) throw new Error("Value '" + value + "' can't be converted to Int");
			}, prepareFunctionToInt);
		}
		
		public function asFloat():Assure {
			return check(function(value:*):void {
				var testint:Number = parseFloat("" + value);
				if (isNaN(testint)) throw new Error("Value '" + value + "' can't be converted to Float");
			}, prepareFunctionToFloat);
		}
		
		public function asString():Assure {
			return check(function(value:*):void {
				// noop. parsing to string should never be a problem, even for null and undefined
			}, prepareFunctionToString);
		}
		
		public function asSelf():Assure {
			return check(function(value:*):void { /* noop */ }, prepareFunctionIdentity);
		}
		
		public function forProperties(schema:Object):Assure {
			return check(function(value:*):void {
				for (var key:* in schema) {
					if (!Assure(schema[key]).validate(value[key])) throw new Error("!schema " + [value, value[key], schema[key]]);
				}
			});
		}
		
		public function deep(path_to_value:Array, assure:Assure):Assure {
			return check(function(value:*):void {
				var v:*;
				var arraycopy:Array = [];
				for (var i:int = 0; i < path_to_value.length; i++) {
					arraycopy.push(path_to_value[i]);
				}
				if (arraycopy.length === 0) {
					v = value;
				} else {
					var p:* = value;
					while (arraycopy.length > 0) {
						try {
							if (arraycopy.length > 1) {
								p = p[arraycopy[0]];
							} else {
								v = p[arraycopy[0]];
							}
							arraycopy.shift();
						} catch (e:Error) {
							v = undefined;
							break;
						}
					}
				}
				if(!assure.validate(v)) throw Error("!deep assure for " + v);
			});
		}
		
		public function notEmpty():Assure {
			return check(function(value:*):void {
				if (value === undefined) throw new Error("!NOTempty is undefined " + value);
				if (value === null) throw new Error("!NOTempty is null " + value);
				if (value is Array && (value as Array).length === 0) throw new Error("!NOTempty is empty array " + value);
				if (value === "") throw new Error("!NOTempty is empty String " + value);
				if (value is Number && isNaN(value)) throw new Error("!NOTempty is NaN number" + value);
			});
		}
		
		public function validate(...values):Boolean {
			if (_func == null) return false;
			
			for each(var v:* in values) {
				try {
					if (_is_optional && Assure.v.equalsOneOf(null, undefined).validate(v)) {
						// just relax
					} else {
						_func.apply(null, [v]);
					}
				} catch (e:Error) {
					trace(e.message);
					return false;
				}
			}
			return true;
		}
		
		private function prepareFunctionToInt(value:*):* {
			return parseInt("" + value);
		}
		
		private function prepareFunctionToFloat(value:*):* {
			return parseFloat("" + value);
		}
		
		private function prepareFunctionToString(value:*):* {
			return "" + value;
		}
		
		private function prepareFunctionIdentity(value:*):* {
			return value;
		}
	}
}