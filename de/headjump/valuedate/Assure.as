package de.headjump.valuedate {
	
	public class Assure {
		private var _func:Function;
		private var _is_optional:Boolean;
		
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
		}
		
		protected function check(func:Function):Assure {
			var old:Function = _func;
			_func = function(value:*) {
				if (old != null) old.apply(null, [value]);
				func.apply(null, [value]);
			}
			return this;
		}
		
		public function isA(c:Class):Assure {
			return check(function(value:*) {
				if (!(value is c)) throw new Error("!ofClass " + [value, c]);
			});
		}
		
		public function forEach(a:Assure):Assure {
			return check(function(value:*) {
				for each (var c:* in value) {
					if (!a.validate(c)) throw new Error("!forEach " + [value, c, a]);
				}
			});
		}
		
		public function isAn(c:Class):Assure {
			return check(value.isA(c).assure_function);
		}
		
		public function equalsOneOf(...params):Assure {
			// value equals ONE of params
			return check(function(value:*) {
				for each(var p:* in params) {
					if (value === p) return;
				}
				throw new Error("!equals " + [value, params])
			});
		}
		
		public function oneOf(... assures):Assure {
			return check(function(value:*) {
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
		
		public function inRange(min:Number, max:Number):Assure {
			return check(function(value:*) {
				if (!(value is Number)) throw new Error("!inRange value not a Number " + [value]);
				if (value < min) throw new Error("!inRange smaller min " + [value, min]);
				if (value > max) throw new Error("!inRange greater max " + [value, max]);
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
			return check(function(value:*) {
				for each(var p:* in params) {
					if (value ===p) throw new Error("!NOTequals " + [value, p, params]);
				}
			});
		}
		
		public function forProperties(schema:Object):Assure {
			return check(function(value:*) {
				for (var key:* in schema) {
					if (!Assure(schema[key]).validate(value[key])) throw new Error("!schema " + [value, value[key], schema[key]]);
				}
			});
		}
		
		public function notEmpty():Assure {
			return check(function(value:*) {
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
	}
}