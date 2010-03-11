package de.headjump.tests {
	import asunit.framework.TestCase;	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import de.headjump.valuedate.Assure;
	
	/**
	* ...
	* @author Dennis Treder (info@dennistreder.de)
	*/
	
	public class TestValuedate extends TestCase {
		public static const REPEAT_EACH:int = 3; // to make sure the assure function is repeatable! important!

		public function TestValuedate(testMethod:String = null) {
			super(testMethod);
		}
		
		private function validates(assure:Assure, ... values):void {
			for (var i:int = 0; i < REPEAT_EACH; i++) {
				assertTrue(assure.validate.apply(null, values));
			}
		}
		
		private function fails(assure:Assure, ... values):void {
			for (var i:int = 0; i < REPEAT_EACH; i++) {
				assertFalse(assure.validate.apply(null, values));
			}
		}
		
		public function testIsA():void {
			validates(Assure.value.isA(Number),12);
			fails(Assure.value.isA(Number),{});
		}
		
		public function testChainedAssertion():void {
			validates(Assure.value.isA(Number).inRange(10, 15).equals(12), 12);
			fails(Assure.value.isA(Number).inRange(10, 15).equals(12), "test");
		}
		
		public function testOneOf():void {
			validates(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)),12);
			validates(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)),"hello");
			fails(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)),{ name: "klaus"});
		}
		
		public function testValidates():void {
			validates(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)), 12, "test");
			fails(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)), 12, {});
		}
		
		public function testNotEquals():void {
			validates(Assure.value.notEquals(12), 13, 14, 15, 16);
			validates(Assure.value.notEqualsOneOf(12, 13, 14), 15, 16, 17);
			fails(Assure.value.notEquals(12), 12, 14, 15, 16);
			fails(Assure.value.notEqualsOneOf(12, 13, 14), 14);
		}
		
		public function testPredefinedAssure():void {
			var func:Assure = Assure.value.oneOf(Assure.value.inRange(10, 20), Assure.value.isA(String));
			validates(Assure.value.assures(func), "hello");
			validates(Assure.value.assures(func), 15);
			fails(Assure.value.assures(func), {});
			fails(Assure.value.assures(func), 21);
		}
		
		public function testEquals():void {
			validates(Assure.value.equals(12), 12);
			validates(Assure.value.equalsOneOf("admin", "user"), "admin");
			fails(Assure.value.equals(12), 14);
			fails(Assure.value.equalsOneOf("admin", "user"), "mother");
		}
		
		public function testNotEmpty():void {
			validates(Assure.value.notEmpty(), "hello", [1], 12, new Sprite(), { "test": "1"});
			fails(Assure.value.notEmpty(), []);
			fails(Assure.value.notEmpty(), "");
			fails(Assure.value.notEmpty(), NaN);
			fails(Assure.value.notEmpty(), undefined);
			fails(Assure.value.notEmpty(), null);
		}
		
		public function testProperties():void {
			var admin:Object = {
				name: "Mr. Admin",
				role: "admin",
				age: 29
			}
			var user:Object = {
				name: "Userman",
				role: "user",
				age: 23
			}
			var mother:Object = {
				name: "Your Mother",
				role: "mother",
				age: 88
			}
			var val:Assure = Assure.value.forProperties( {
				name: Assure.value.isA(String).notEmpty(),
				role: Assure.value.equalsOneOf("admin", "user"),
				age: Assure.value.isA(Number).inRange(5, 99)
			}) 
			validates(Assure.value.assures(val), admin);
			validates(Assure.value.assures(val), user);
			fails(Assure.value.assures(val), mother);
		}
		
		public function testNested():void {
			var admin:Object = {
				name: "Mr. Admin",
				role: "admin",
				age: 29,
				info: {
					title: "hello world"
				}
			}
			var user:Object = {
				name: "Userman",
				role: "user",
				age: 23
			}
			var user2:Object = {
				name: "Mr. User",
				role: "user",
				age: 31,
				info: {
					title: 12
				}
			}
			var val:Assure = Assure.value.forProperties( {
				name: Assure.value.isA(String).notEmpty(),
				role: Assure.value.oneOf(Assure.value.equals("admin"), Assure.value.equals("user")),
				age: Assure.value.isA(Number).inRange(5, 99),
				info: Assure.value.oneOf(Assure.value.equals(undefined), Assure.value.forProperties( {
					title: Assure.value.isA(String)
				}))
			}) 
			validates(Assure.value.assures(val), admin);
			validates(Assure.value.assures(val), user);
			fails(Assure.value.assures(val), user2);
		}
		
		public function testV():void {
			// short writing
			validates(Assure.v.equals(12), 12);
		}
		
		public function testOptionalValue():void {
			var admin:Object = {
				name: "Mr. Admin",
				role: "admin",
				age: 29,
				info: {
					title: "hello world"
				}
			}
			var user:Object = {
				name: "Userman",
				role: "user",
				age: 23
			}
			var user2:Object = {
				name: "Mr. User",
				role: "user",
				age: 31,
				info: {
					title: 12
				}
			}
			var val:Assure = Assure.value.forProperties( {
				name: Assure.value.isA(String).notEmpty(),
				role: Assure.value.equalsOneOf("admin", "user"),
				age: Assure.value.isA(Number).inRange(5, 99),
				info: Assure.optional_value.forProperties( {
					title: Assure.value.isA(String)
				})
			}); 
			val.validate(admin);
			val.validate(user);
			val.validate(user2);
		}
		
		public function testForEach():void {
			var schema:Assure = Assure.value.forEach(Assure.value.isA(Number).inRange(1, 15));
			
			var a1:Array = [1, 2, 3, 4, 5, 6];	// ok
			var a2:Array = [1, 2, 20];			// fails
			var a3:Array = [1, 2, "test"];		// fails
			
			validates(schema, a1);
			fails(schema, a2);
			fails(schema, a3);
		}
		
		public function testForEachWithProperties():void {
			var o1:Object = {
				"val1" : {
					"name" : "Name 1",
					"age" : 99
				},
				"val2" : {
					"name" : "Name 2",
					"age" : 99
				}
			}
			var o2:Object = {
				"val1" : {
					"name" : "Name 1",
					"age" : 99
				},
				"val2" : {
					"name" : "Name 2",
					"age" : "very old"
				}
			}
			
			var schema:Assure = Assure.value.forEach(Assure.value.forProperties( {
				"name" : Assure.value.isA(String),
				"age" : Assure.value.isA(Number)
			}));
			
			validates(schema, o1);
			fails(schema, o2);
		}
		
		public function testNot():void {
			validates(Assure.v.not(Assure.v.isA(Number)), "I'm a string");
			
			var noone_special:Assure = Assure.v.not(Assure.v.equalsOneOf("admin", "user", "boss"));
			validates(noone_special, "myself");
			validates(noone_special, "your mother");
			fails(noone_special, "boss");
		}
		
		public function testNotNull():void {
			validates(Assure.v.notNull(), 1);
			validates(Assure.v.notNull(), "hello");
			fails(Assure.v.notNull(), null);
			fails(Assure.v.notNull(), undefined);
			var o:Object;
			fails(Assure.v.notNull(), o);
			validates(Assure.v.forProperties( { "test" : Assure.v.notNull() } ), { "test" : [] } );
			fails(Assure.v.forProperties( { "test" : Assure.v.notNull() } ), { "test2" : "hallo" } );
		}
		
		public function testAsInt():void {
			validates(Assure.v.asInt().isA(Number).equals(123), "123");
			fails(Assure.v.asInt(), "not a number");
		}
		
		public function testAsFloat():void {
			validates(Assure.v.asFloat().isA(Number).equals(123.45), "123.45");
			fails(Assure.v.asFloat(), "not a number");
		}
		
		public function testAsString():void {
			validates(Assure.v.asString().isA(String).equals("123.45"), 123.45);
		}
		
		public function testAsSelf():void {
			validates(Assure.v.asInt().asSelf().equals("123"), "123");
		}
		
		public function testTrueFor():void {
			var length3:Function = function(value:*):Boolean {
				if (value is Array && (value as Array).length === 3) return true;
				return false;
			}
			
			validates(Assure.v.trueFor(length3), [1, 2, 3]);
			fails(Assure.v.trueFor(length3), [1, 2]);
			fails(Assure.v.trueFor(length3), "Hello");
		}
		
		public function testDeepOK():void {
			var o:Object = {
				"1": {
					"2": 3
				},
				"2": [0, 0, 0, [0, 0, 0, 0, "test"]]
			}
			validates(Assure.v.deep(["1", "2"], Assure.v.isA(Number).equals(3)), o);
			validates(Assure.v.deep(["2", 3, 4], Assure.v.isA(String).equals("test")), o);
			validates(Assure.v.deep([], Assure.v.equals(2)), 2);
			validates(Assure.v.deep([], Assure.v.notNull()), "test");
			fails(Assure.v.deep(["update"], Assure.v.notNull()), {} );
			validates(Assure.v.deep("1.2", Assure.v.isA(Number).equals(3)), o);
			validates(Assure.v.deep("2.3.4", Assure.v.isA(String).equals("test")), o);
			validates(Assure.v.deep("", Assure.v.equals(2)), 2);
			validates(Assure.v.deep("", Assure.v.notNull()), "test");
			fails(Assure.v.deep("update", Assure.v.notNull()), {} );
		}
		
		public function testDeepError():void {
			var o:Object = {
				"1": {
					"2": 3
				},
				"2": [0, 0, 0, [0, 0, 0, 0, "test"]]
			}
			fails(Assure.v.deep([3, 5], Assure.v.notNull()), o);
			fails(Assure.v.deep([3, 5], Assure.v.notNull()), { } );
			fails(Assure.v.deep("3.5", Assure.v.notNull()), o);
			fails(Assure.v.deep("3.5", Assure.v.notNull()), { } );
		}
		
		public function testDeepOptional():void {
			var o:Object = {
				"1": {
					"2": 3
				},
				"2": [0, 0, 0, [0, 0, 0, 0, "test"]]
			}
			validates(Assure.v.deep([3, 5], Assure.optional.notNull()), o); // optional
			validates(Assure.v.deep([], Assure.optional.notNull()), null); // optional
			validates(Assure.optional.deep([], Assure.v.notNull()), null); // optional
		}
		
		public function testDeepUndefined():void {
			var o:Object = {
				"test": "test",
				"test2": {}
			}
			validates(Assure.v.deep(["test"], Assure.v.notNull()), o);
			validates(Assure.v.deep(["test2"], Assure.v.notNull()), o);
			fails(Assure.v.deep(["update"], Assure.v.notNull()), o);
		}
		
		public function testDeepUndefinedSaved():void {
			var a:Assure = Assure.v.deep(["update"], Assure.v.notNull());
			validates(a, { "update": [1,2,3] } );
			validates(a, { "update": 123 } );
			fails(a, {} );
			fails(a, undefined );
		}
	}
}