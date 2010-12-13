package de.headjump.valuedate {
	import de.headjump.tests.TestValuedate;
	
	public class Assure {
		public static const VERSION:Number = 0.95;
		private var _func:Function;
		private var _is_optional:Boolean;
		private var _prepare_value:Function;
		private static var MAIL_REGEXP:RegExp = /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i;
    private static var _trace:Function = null;
    private static var _do_trace:Boolean = false;
    private static var _error_trace:String;
    private static var _trace_prefix:String = "";

    public static function set trace_function(val:Function):void {
      _trace = val;
    }

		public static function get value():Assure {
			return new Assure();
		}

    private static function traceDown():void {
      if(!_do_trace) return;
      _trace_prefix += "  ";
    }
    private static function traceUp():void {
      if(!_do_trace) return;
      _trace_prefix.substr(0, _trace_prefix.length - 2);
    }

    /**
     * Traces output, if _do_trace
     */
    private static function tr(what:*):void {
      if(_do_trace) {
        _error_trace += (_error_trace === "" ? "" : "\n") + _trace_prefix + what;
      }
    }

    /**
     * validates assure and shows trace if !valid
     * @param a           Assure
     * @param values      Values to validate for
     * @return            valid?
     */
    public static function withErrorTrace(a:Assure, ...values):Boolean {
      var res:Boolean;

      _do_trace = true;
      _error_trace = "";
      _trace_prefix = "";

      res = a.validate.apply(null, values);

      if(!res) {
        if(_trace !== null) {
          _trace.apply(null, [ "ASSURE !valid:\n" + _error_trace ]);
        } else {
          trace("ASSURE !valid:\n" + _error_trace);
        }
      }

      _do_trace = false;
      return res;
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
        tr("for each:");
        traceDown();
				for each (var c:* in value) {
					if (!a.validate(c)) throw new Error("!forEach " + [value, c, a]);
				}
        traceUp();
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
        tr("one of:");
        traceDown();
				for each(var a:Assure in assures) {
					if (a.validate(value)) {
            traceUp();
            return;
          }
				}
        traceUp();
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
        tr("for properties:");
        traceDown();
				for (var key:* in schema) {
          tr("'" + key + "'");
					if (!Assure(schema[key]).validate(value[key])) throw new Error("!schema " + [value, value[key], schema[key]]);
				}
        traceUp();
			});
		}
		
		/**
		 * Validates a single value "deep" inside the objects structure
		 * @param	path_to_value	Array ["parent","child","child"] || String "parent.child.child" (String will be split by ".")
		 * @param	assure		Assure to validate deep value with
		 */public function deep(path_to_value:*, assure:Assure):Assure {
			return check(function(value:*):void {
        tr("deep '" + path_to_value + "'");
        traceDown();
				var v:*;
				var arraycopy:Array = [];
				var a:Array;
				if (path_to_value is Array) {
					a = path_to_value as Array;
				} else if (path_to_value is String) {
					var str_p:String = path_to_value as String;
					a = str_p.length > 0 ? str_p.split(".") : [];
				} else {
					throw new Error("Assure.deep wrong path format (should be String || Array): " + path_to_value);
				}
				for (var i:int = 0; i < a.length; i++) {
					arraycopy.push(a[i]);
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
        traceUp();
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
		
		public function isEmail():Assure {
			return check(function(email:String):void {
				if (!email.match(MAIL_REGEXP)) throw new Error("!isEmail " + email);
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
					tr("ERROR: " + e.message);
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