package de.headjump.tests {
	import asunit.framework.TestCase;	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	* ...
	* @author Dennis Treder (info@dennistreder.de)
	* ### tests require asunit test framework! ###
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
		
		public function testFunc():void {
			var func:Assure = Assure.value.oneOf(Assure.value.inRange(10, 20), Assure.value.isA(String));
			assertTrue(Assure.value.func(func).validate("hello"));
			assertTrue(Assure.value.func(func).validate(15));
			assertFalse(Assure.value.func(func).validate({}));
			assertFalse(Assure.value.func(func).validate(21));
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
			assertTrue(Assure.value.func(val).validate(admin));
			assertTrue(Assure.value.func(val).validate(user));
			assertFalse(Assure.value.func(val).validate(mother));
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
			assertTrue(Assure.value.func(val).validate(admin));
			assertTrue(Assure.value.func(val).validate(user));
			assertFalse(Assure.value.func(val).validate(user2));
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
				role: Assure.value.oneOf(Assure.value.equals("admin"), Assure.value.equals("user")),
				age: Assure.value.isA(Number).inRange(5, 99),
				info: Assure.optional_value.forProperties( {
					title: Assure.value.isA(String)
				})
			}) 
			assertTrue(Assure.value.func(val).validate(admin));
			assertTrue(Assure.value.func(val).validate(user));
			assertFalse(Assure.value.func(val).validate(user2));
		}
		
	}	
}