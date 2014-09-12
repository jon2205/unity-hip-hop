package ;

// based on HUGS https://github.com/proletariatgames/HUGS/blob/master/hugs/HUGSWrapper.hx

import unityengine.GameObject;
import unityengine.Component;
import unityengine.Quaternion;
import unityengine.Transform;
import unityengine.Vector3;
import unityengine.Vector2;
import unityengine.Matrix4x4;
import unityengine.Animation;
import unityengine.AnimationState;

class MonoTools 
{
	public static function main(){}
}

class ComponentMethods
{
	public inline static function getComponent<T>(c:Component, type:Class<T>):T
	return cast c.GetComponent(cs.Lib.toNativeType(type));

	public static function getComponentInChildrenOfType<T>(c:Component, type:Class<T>) : T
	return cast c.GetComponentInChildren(cs.Lib.toNativeType(type));

	public static function getComponentsInChildrenOfType<T>(c:Component, type:Class<T>, includeInactive:Bool=false) : NativeArrayIterator<T>
	return cast new NativeArrayIterator<Component>(c.GetComponentsInChildren(cs.Lib.toNativeType(type), includeInactive));

	inline public static function getOrAddComponent<T>(c:Component, type:Class<T>):T
	return GameObjectMethods.getOrAddComponent(c.gameObject, type);

	inline public static function getChildGameObject(c:Component, name:String):GameObject
	return GameObjectMethods.getChildGameObject(c.gameObject, name);

	inline public static function getParentComponent<T>(c:Component, type:Class<T>):T
	return GameObjectMethods.getParentComponent(c.gameObject, type);
}

class EnumeratorMethods
{
	public static inline function iterator(enumerable:IEnumerable) : Iterator<Dynamic>
	return new EnumeratorAdapter<Dynamic>(enumerable.GetEnumerator());

	public static inline function iteratorT<T>(enumerable:IEnumerable, type:Class<T>) : Iterator<T>
	return new EnumeratorAdapter<T>(enumerable.GetEnumerator());
}

class GameObjectMethods
{
	inline public static function getComponent<T>(g:GameObject, type:Class<T>):T
	return cast g.GetComponent(cs.Lib.toNativeType(type));

	inline public static function addComponent<T>(g:GameObject, type:Class<T>):T
	return cast g.AddComponent(cs.Lib.toNativeType(type));

	inline public static function getComponentsOfType<T>(g:GameObject, type:Class<T>) : NativeArrayIterator<T>
	return cast new NativeArrayIterator<Component>(g.GetComponents(cs.Lib.toNativeType(type)));

	public static function getComponentsInChildrenOfType<T>(g:GameObject, type:Class<T>, includeInactive:Bool=false) : NativeArrayIterator<T>
	return cast new NativeArrayIterator<Component>(g.GetComponentsInChildren(cs.Lib.toNativeType(type), includeInactive));

	inline public static function getOrAddComponent<T>(c:GameObject, type:Class<T>):T {
		var o:T = getComponent(c, type);
		return o == null ? GameObjectMethods.addComponent(c.gameObject, type) : o;
	}

	public static function getChildGameObject(gameObject:GameObject, name:String):GameObject {
		for (t in getComponentsInChildrenOfType(gameObject, Transform)) if (t.gameObject.name == name) return t.gameObject;
		return null;
	}

	public static function getParentComponent<T>(gameObject:GameObject, type:Class<T>):T {
		var cur:GameObject = gameObject;
		var t:Transform = null;
		while ((t = cur.transform.parent) != null) {
			cur = t.gameObject;
			var c:T = getComponent(cur, type);
			if (c != null) return c;
		}
		return null;
	}
}

class QuaternionMethods
{
	inline public static function mulVector3(a:Quaternion, b:Vector3) : Vector3
	return untyped __cs__("a*b");

	inline public static function mul(a:Quaternion, b:Quaternion) : Quaternion
	return untyped __cs__("a*b");

	inline public static function rotatePoint(a:Quaternion, b:Vector3) : Vector3
	return untyped __cs__("a*b");

	inline public static function eq(a:Quaternion, b:Quaternion) : Bool
	return untyped __cs__("a==b");
}

class Vector3Methods
{
	inline public static function add(a:Vector3, b:Vector3) : Vector3
	return untyped __cs__("a+b");

	inline public static function sub(a:Vector3, b:Vector3) : Vector3
	return untyped __cs__("a-b");

	inline public static function mul(a:Vector3, b:Single) : Vector3
	return untyped __cs__("b*a");

	inline public static function div(a:Vector3, b:Single) : Vector3
	return untyped __cs__("a/b");

	inline public static function eq(a:Vector3, b:Vector3) : Bool
	return untyped __cs__("a==b");

	inline public static function toVector2(a:Vector3)
	return new Vector2(a.x, a.y);
}

class Matrix4x4Methods
{
	inline public static function mul(a:Matrix4x4, b:Matrix4x4) : Matrix4x4
	return untyped __cs__("a*b");
}

@:native("System.Collections.IEnumerator")
extern interface IEnumerator {
  function MoveNext() : Bool;
  function Reset() : Void;
}

@:native("System.Collections.IEnumerable")
extern interface IEnumerable {
	function GetEnumerator() : IEnumerator;
}

@:keep
class EnumeratorAdapter<T>
{
	public var enumerator(default, null):IEnumerator;
	inline public function new(enumerator:IEnumerator) {
		this.enumerator = enumerator;
	}

	public function next() : T
    // Current is not exported, because currently vars are not exported from interfaces
    return untyped __cs__("(T)this.enumerator.Current");

	public function hasNext() : Bool
	return this.enumerator.MoveNext();
}

@:keep
class NativeArrayIterator<T>
{
	public var array(default, null):cs.NativeArray<T>;
	public var i:Int;
	inline public function new(ar:cs.NativeArray<T>) {
		this.array = ar;
		this.i = 0;
	}

	public inline function next() : T return this.array[i++];

	public inline function hasNext() : Bool return i < this.array.Length;

	inline public function reset():Void i = 0;

	inline public function keys():IntIterator return 0...array.Length;

	public inline function haxeArray():Array<T> {
		var a:Array<T> = [];
		for (e in this) a.push(e);
		return a;
	}
}

class AnimationMethods
{
	public inline static function getState(a:Animation, name:String):AnimationState
	return untyped __cs__("a[name]");
}