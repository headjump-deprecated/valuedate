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

		public function TestValuedate(testMethod:String = null) {
			super(testMethod);
		}
		
		public function testIsA():void {
			assertTrue(Assure.value.isA(Number).validate(12));
			assertFalse(Assure.value.isA(Number).validate({}));
		}
		
		public function testChainedAssertion():void {
			assertTrue(Assure.value.isA(Number).inRange(10, 15).equals(12).validate(12));
			assertFalse(Assure.value.isA(Number).inRange(10, 15).equals(12).validate("test"));
		}
		
		public function testOneOf():void {
			assertTrue(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)).validate(12));
			assertTrue(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)).validate("hello"));
			assertFalse(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)).validate({ name: "klaus"}));
		}
		
		public function testValidates():void {
			assertTrue(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)).validate(12, "test"));
			assertFalse(Assure.value.oneOf(Assure.value.isA(Number), Assure.value.isA(String)).validate(12, {}));
		}
		
		public function testNotEquals():void {
			assertTrue(Assure.value.notEquals(12).validate(13, 14, 15, 16));
			assertTrue(Assure.value.notEqualsOneOf(12, 13, 14).validate(15, 16, 17));
			assertFalse(Assure.value.notEquals(12).validate(12, 14, 15, 16));
			assertFalse(Assure.value.notEqualsOneOf(12, 13, 14).validate(14));
		}
		
		public function testPredefinedAssure():void {
			var func:Assure = Assure.value.oneOf(Assure.value.inRange(10, 20), Assure.value.isA(String));
			assertTrue(Assure.value.assures(func).validate("hello"));
			assertTrue(Assure.value.assures(func).validate(15));
			assertFalse(Assure.value.assures(func).validate({}));
			assertFalse(Assure.value.assures(func).validate(21));
		}
		
		public function testEquals():void {
			assertTrue(Assure.value.equals(12).validate(12));
			assertTrue(Assure.value.equalsOneOf("admin", "user").validate("admin"));
			assertFalse(Assure.value.equals(12).validate(14));
			assertFalse(Assure.value.equalsOneOf("admin", "user").validate("mother"));
		}
		
		public function testNotEmpty():void {
			assertTrue(Assure.value.notEmpty().validate("hello", [1], 12, new Sprite(), { "test": "1"}));
			assertFalse(Assure.value.notEmpty().validate([]));
			assertFalse(Assure.value.notEmpty().validate(""));
			assertFalse(Assure.value.notEmpty().validate(NaN));
			assertFalse(Assure.value.notEmpty().validate(undefined));
			assertFalse(Assure.value.notEmpty().validate(null));
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
			assertTrue(Assure.value.assures(val).validate(admin));
			assertTrue(Assure.value.assures(val).validate(user));
			assertFalse(Assure.value.assures(val).validate(mother));
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
			assertTrue(Assure.value.assures(val).validate(admin));
			assertTrue(Assure.value.assures(val).validate(user));
			assertFalse(Assure.value.assures(val).validate(user2));
		}
		
		public function testV():void {
			// short writing
			assertTrue(Assure.v.equals(12).validate(12));
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
			
			assertTrue(schema.validate(a1));
			assertFalse(schema.validate(a2));
			assertFalse(schema.validate(a3));
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
			
			assertTrue(schema.validate(o1));
			assertFalse(schema.validate(o2));
		}
		
		public function testNot():void {
			assertTrue(Assure.v.not(Assure.v.isA(Number)).validate("I'm a string"));
			
			var noone_special:Assure = Assure.v.not(Assure.v.equalsOneOf("admin", "user", "boss"));
			assertTrue(noone_special.validate("myself"));
			assertTrue(noone_special.validate("your mother"));
			assertFalse(noone_special.validate("boss"));
		}
		
		public function testNotNull():void {
			assertTrue(Assure.v.notNull().validate(1));
			assertTrue(Assure.v.notNull().validate("hello"));
			assertFalse(Assure.v.notNull().validate(null));
			assertFalse(Assure.v.notNull().validate(undefined));
			var o:Object;
			assertFalse(Assure.v.notNull().validate(o));
			assertTrue(Assure.v.forProperties( { "test" : Assure.v.notNull() } ).validate( { "test" : [] } ));
			assertFalse(Assure.v.forProperties( { "test" : Assure.v.notNull() } ).validate( { "test2" : "hallo" } ));
		}
		
	}
}