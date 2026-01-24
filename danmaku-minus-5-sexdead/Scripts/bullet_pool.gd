# bullet_pool.gd
extends Node
class_name BulletPool

# Singleton instance
static var instance: BulletPool = null

# Pool settings
@export var initial_pool_size: int = 50
@export var max_pool_size: int = 1000
@export var bullet_scene: PackedScene

# Pool containers
var available_bullets: Array[Node2D] = []
var active_bullets: Array[Node2D] = []

# Statistics
var created_count: int = 0
var recycled_count: int = 0

func _ready():
	# Initialize singleton
	if instance == null:
		instance = self
	else:
		queue_free()
		return
	
	# Pre-instantiate bullets
	prepopulate_pool()
	
	print("BulletPool initialized with %d bullets" % available_bullets.size())

func prepopulate_pool():
	if bullet_scene == null:
		print("BulletPool: No bullet scene assigned!")
		return
	
	for i in range(initial_pool_size):
		var bullet = create_new_bullet()
		bullet.hide()
		bullet.set_process(false)
		bullet.set_physics_process(false)
		bullet.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(bullet)
		available_bullets.append(bullet)

func create_new_bullet() -> Node2D:
	created_count += 1
	var bullet = bullet_scene.instantiate()
	# Configure bullet for pooling
	bullet.tree_exiting.connect(_on_bullet_tree_exiting.bind(bullet))
	return bullet

# Get a bullet from the pool
func get_bullet() -> Node2D:
	var bullet: Node2D
	
	if available_bullets.size() > 0:
		# Reuse from pool
		bullet = available_bullets.pop_back()
		recycled_count += 1
	else:
		# Create new bullet if pool is empty but under max size
		if get_child_count() < max_pool_size:
			bullet = create_new_bullet()
			add_child(bullet)
		else:
			# No available bullets, recycle oldest active bullet
			print("BulletPool: Pool exhausted, reusing oldest bullet")
			if active_bullets.size() > 0:
				bullet = active_bullets[0]
				active_bullets.remove_at(0)
				recycle_bullet_directly(bullet)
			else:
				# Emergency fallback
				bullet = bullet_scene.instantiate()
				get_parent().add_child(bullet)
				return bullet
	
	# Configure bullet for use
	bullet.show()
	bullet.set_process(true)
	bullet.set_physics_process(true)
	bullet.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Remove from parent and clear transform
	if bullet.get_parent():
		bullet.get_parent().remove_child(bullet)
	
	active_bullets.append(bullet)
	return bullet

# Return bullet to pool
func return_bullet(bullet: Node2D):
	if not is_instance_valid(bullet):
		return
	
	# Remove from active list
	var index = active_bullets.find(bullet)
	if index != -1:
		active_bullets.remove_at(index)
	
	# Reset bullet state
	bullet.hide()
	bullet.set_process(false)
	bullet.set_physics_process(false)
	bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet.position = Vector2.ZERO
	bullet.rotation = 0
	
	# Clear any signals
	if bullet.has_signal("tree_exiting"):
		bullet.tree_exiting.disconnect(_on_bullet_tree_exiting)
	
	# Re-add to pool
	if not bullet in available_bullets:
		available_bullets.append(bullet)
	
	# Reconnect signal
	bullet.tree_exiting.connect(_on_bullet_tree_exiting.bind(bullet))

# Direct recycling (for emergency reuse)
func recycle_bullet_directly(bullet: Node2D):
	if not is_instance_valid(bullet):
		return
	
	# Reset bullet
	bullet.hide()
	bullet.position = Vector2.ZERO
	bullet.rotation = 0
	bullet.linear_velocity = Vector2.ZERO
	bullet.angular_velocity = 0
	
	# Return to available pool
	if not bullet in available_bullets:
		available_bullets.append(bullet)

func _on_bullet_tree_exiting(bullet: Node2D):
	# Handle bullet being freed outside of pool
	if bullet in active_bullets:
		active_bullets.erase(bullet)
	if bullet in available_bullets:
		available_bullets.erase(bullet)

# Statistics
func get_statistics() -> Dictionary:
	return {
		"total_bullets": get_child_count(),
		"available": available_bullets.size(),
		"active": active_bullets.size(),
		"created": created_count,
		"recycled": recycled_count,
		"reuse_rate": float(recycled_count) / max(created_count, 1) * 100.0
	}

# Cleanup all bullets
func cleanup():
	for bullet in active_bullets:
		if is_instance_valid(bullet):
			bullet.queue_free()
	
	for bullet in available_bullets:
		if is_instance_valid(bullet):
			bullet.queue_free()
	
	active_bullets.clear()
	available_bullets.clear()

# Static helper methods
static func get_bullet_from_pool() -> Node2D:
	if instance == null:
		print("BulletPool not initialized!")
		return null
	return instance.get_bullet()

static func return_bullet_to_pool(bullet: Node2D):
	if instance == null:
		print("BulletPool not initialized!")
		bullet.queue_free()
		return
	instance.return_bullet(bullet)

static func get_stats():
	if instance == null:
		return {"error": "BulletPool not initialized"}
	return instance.get_statistics()
