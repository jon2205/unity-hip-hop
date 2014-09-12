package game;

// это обязательно вписывать в каждый файл:
import unityengine.*;
using MonoTools;
using StringTools;
using Math;

class Player extends MonoBehaviour
{
	// рефлексия в редакторе работает автоматически
	
	public var jumpForce = 100.0; // нужно называть переменные в "camelCase" -> в редакторе будет как "Camel Case"
	public var jumpForceTotalAmount = 1000.0;

	public var shieldRestoreSeconds = 7.0;
	public var shieldSpendSeconds = 2.0;

	@:meta(UnityEngine.Range(0,100)) // границы
	public var maxSpeed = 10.0; // тип переменной можно не указывать, если компилятор догадается о типе сам, конечно
	
	// приватные поля, слово private можно не писать
	@:meta(UnityEngine.HideInInspector) // скрываем от редактора
	var speed = 0.0;

	@:meta(UnityEngine.HideInInspector)
	var jumpForceAmount = 0.0;

	@:meta(UnityEngine.HideInInspector)
	var jumped = false;
  
    @:meta(UnityEngine.HideInInspector)
	var shieldAmount = 0.0;

	// события
	public function Awake() {
		Debug.Log("woke up!");
		jumpForceAmount = jumpForceTotalAmount;
		shieldAmount = shieldSpendSeconds;
	}

	public function FixedUpdate() {
		var rigidbody = getComponent(Rigidbody2D);

		// бежим вправо с фиксированной скоростью
		speed = maxSpeed;
		this.transform.position = new Vector3(this.transform.position.x + speed / 60.0, this.transform.position.y, this.transform.position.z);
		// проверим где нажатие на экран
		// TODO адаптировать под мульти тач
		var isLeft = (Input.mousePosition.x / Screen.width) < 0.5;

		function isGrounded()
		{
			var groundCheck = transform.Find("GroundCheck");
			if(groundCheck == null) return false;
			var grounded = Physics2D.Linecast(transform.position.toVector2(), groundCheck.position.toVector2(), 1 << LayerMask.NameToLayer("Ground"));
			return (grounded != null);
		}

		// нажато? го!
		if (Input.GetButton("Fire1") && isLeft) {
			if(isLeft) {
				// прыгаем
				if(!jumped) { 
					if(isGrounded()) 
					jumped = true;
				} 

				if(jumped) {
					if(jumpForceAmount > 0){			
				 		rigidbody.AddForce(new Vector2(0, jumpForce));
				 		jumpForceAmount -= jumpForce;
				 	} else jumped = false;
				}
			} else {
				// проходим с щитом
			}
		} else {
			// чисто для теста зарегеним весь обьем силы прыжка
			if(isGrounded())
			jumpForceAmount = jumpForceTotalAmount;
		}

		if (Input.GetButton("Fire1") && !isLeft) {
            if(shieldAmount > 0) {
				Physics2D.IgnoreLayerCollision(LayerMask.NameToLayer("Player"), LayerMask.NameToLayer("DieOrDisable"), true);
              	shieldAmount -= Time.fixedDeltaTime;
            } else Physics2D.IgnoreLayerCollision(LayerMask.NameToLayer("Player"), LayerMask.NameToLayer("DieOrDisable"), false);
		} else {
			Physics2D.IgnoreLayerCollision(LayerMask.NameToLayer("Player"), LayerMask.NameToLayer("DieOrDisable"), false);
          	if(shieldAmount < shieldSpendSeconds)
              shieldAmount += Time.fixedDeltaTime * shieldSpendSeconds / shieldRestoreSeconds;
		}

		var shieldDebugBarForeground = GameObject.Find("ShieldDebugBarForeground");
		if(shieldDebugBarForeground != null)
			shieldDebugBarForeground.transform.localScale = new Vector3(shieldAmount / shieldSpendSeconds, 1, 1);
	}

	public function OnTriggerEnter2D(col:Collider2D)
	{
		// проверка столкновений:
		if(col.gameObject.layer == LayerMask.NameToLayer("Die") || col.gameObject.layer == LayerMask.NameToLayer("DieOrDisable"))
		{
			Debug.Log("Die!");
			Application.LoadLevel (Application.loadedLevelName);
		}
	}
}