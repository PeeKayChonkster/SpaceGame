using Godot;
using static Godot.GD;
using System;

public class Player : Node2D
{
	[Export]
	private NodePath shipPath;

	private PackedScene destReticlePrefab;
	public KinematicBody2D ship;
	private Node camera;
	private Node controller;
	private Vector2? moveTarget = Vector2.Zero;
	public Vector2 velocity = Vector2.Zero;
	private Node destReticle;
	private bool screenTouch = false;
	private float interactDistance = 50.0f;
	private Node followTarget;
	private bool dead = false;
	private Node attackTarget;
	private Vector2 lastCursorScreenPosition = Vector2.Zero;
	private Node moveCursor;

	public override void _Ready()
	{
		Transform2D t;
	}

 // Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		if(!dead && moveCursor != null)
		{

		}
	}

	private void HandleMoveCursor()
	{
		if(!screenTouch && followTarget == null)
		{
			Vector2 idlePosition = (Vector2)moveCursor.GetParent().Get("rect_size") / 2.0f - (Vector2)moveCursor.Get("rect_size") / 2.0f;
			Vector2 newRectPosition = (Vector2)GetNode("/root/Tools").Call("LerpVec2", (Vector2)moveCursor.Get("rect_position"), idlePosition, 0.2f);
			moveCursor.Set("rect_position", newRectPosition);
			moveCursor.GetParent().Set("modulate.a", Mathf.Max(((Vector2)moveCursor.Get("rect_position") - idlePosition).Length() / maxMoveCursorDist - 0.05F, 0.0F));
		}
	}

	public void AddAttackTarget(Node target)
	{
		if(attackTarget != null) RemoveAttackTarget();
		attackTarget = target;
		attackTarget.Connect("death", this, "_OnTargetDeath");
		ship.Call("AddTarget", target);
		// draw firecones if weapons belong to player
		foreach(Node slot in (Godot.Collections.Array)ship.Get("slots"))
		{
			
		}
	}

	public void RemoveAttackTarget()
	{
		attackTarget.Disconnect("death", this, "_OnTargetDeath");
		attackTarget = null;
		ship.Call("RemoveTarget");
	}

	async public void SetReticle()
	{
		lastCursorScreenPosition = GetViewport().GetMousePosition();
		moveCursor.GetParent().Set("rect_global_position", lastCursorScreenPosition - (Vector2)moveCursor.GetParent().Get("rect_size") / 2.0f);
		moveCursor.GetParent().Set("modulate.a", 1.0f);
		while(screenTouch || followTarget != null)
		{
			Vector2 globalMouse = GetGlobalMousePosition();

			// create reticle
			if(destReticle == null && (int)controller.Get("controllMode") == 2)
			{
				destReticle = destReticlePrefab.Instance();
				((Node)GetNode("/root/GameController").Get("world")).AddChild(destReticle);
			}

			if(followTarget != null)
			{
				moveTarget = (Vector2)followTarget.Get("global_position");
			}
			else
			{
				moveTarget = globalMouse;
			}
			Vector2 vec1 = lastCursorScreenPosition;
			Vector2 vec2 = GetViewport().GetMousePosition() - vec1;
			if(vec2.Length() > maxMoveCursorDist) vec2 = vec2.Normalized() * maxMoveCursorDist;
			moveCursor.Set("rect_global_position", vec1 + vec2 - (Vector2)moveCursor.Get("rect_size") / 2.0f);
			await ToSignal(GetTree(), "idle_frame");
		}
	}

	public void Follow(Node obj)
	{
		followTarget = obj;
		SetReticle();
	}

	public void Unfollow()
	{
		followTarget = null;
	}

	public void Interact(Node obj)
	{
		ResetTargets();
		if(obj.GetClass() == "Interactable")
		{
			obj.Call("Interact");
		}
	}

	
	async public void DecreaseSpeed(Node2D target = null, float multiplier = 0.01f)
	{
		ResetTargets(true);
		while(velocity.Length() > 10.0f)
		{
			if(target != null)
				moveTarget = (Vector2)target.Get("global_position");
			velocity *= (1.0f - multiplier);
			await ToSignal(GetTree(), "idle_frame");
		}
		await ToSignal(GetTree(), "idle_frame");
	}

	public void Die()
	{
		dead = true;
	}

	public void OfferLanding(Node planet)
	{
		GetNode("/root/GameController").Call("ui.playerUI.ActivateLandButton", planet);
	}

	public void DenyLanding()
	{
		GetNode("/root/GameController").Call("ui.playerUI.DeactivateLandButton");
	}

	private void ResetTargets(bool resetMoveTarget = false)
	{
		if(resetMoveTarget)
			moveTarget = null;
		screenTouch = false;
		followTarget = null;
		if(destReticle != null)
		{
			destReticle.QueueFree();
			destReticle = null;
		}
	}

	async private void Initialize()
	{
		destReticlePrefab = (PackedScene)ResourceLoader.Load("res://Scenes/UI/DestinationReticle.tscn");
		ship = (KinematicBody2D)this.GetParent();
		camera = this.GetNode("Camera2D");
		if(ship == null)
		{
			ship = (KinematicBody2D)this.GetNode(shipPath);
		}
		controller = this.GetNode("PlayerController");
		ResetTargets(true);

		// TEST
		Node gameController = GetNode("/root/GameController");
		while(!(bool)gameController.Get("initialized"))
			await ToSignal(GetTree(), "idle_frame");
		moveCursor = (Node)gameController.Get("ui.moveCursor");
		moveCursor.GetParent().Set("visible", (int)controller.Get("controllMode") == 1);
		gameController.Call("ui.SetShipUI", ship);
		//
	}

	public void _OnTargetDeath()
	{
		RemoveAttackTarget();
	}
}


