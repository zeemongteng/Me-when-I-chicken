class_name Hitbox 
extends Area3D

signal damaged()

func damage():
	damaged.emit()
