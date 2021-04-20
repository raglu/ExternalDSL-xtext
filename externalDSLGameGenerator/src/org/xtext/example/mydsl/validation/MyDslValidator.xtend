/*
 * generated by Xtext 2.24.0
 */
package org.xtext.example.mydsl.validation

import org.eclipse.xtext.validation.Check
import org.xtext.example.mydsl.myDsl.CarryCapacity
import org.xtext.example.mydsl.myDsl.Durability
import org.xtext.example.mydsl.myDsl.Escapeable
import org.xtext.example.mydsl.myDsl.Health
import org.xtext.example.mydsl.myDsl.Item
import org.xtext.example.mydsl.myDsl.MyDslPackage
import org.xtext.example.mydsl.myDsl.NPC
import org.xtext.example.mydsl.myDsl.Player
import org.xtext.example.mydsl.myDsl.Weight

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class MyDslValidator extends AbstractMyDslValidator {

//	public static val INVALID_NAME = 'invalidName'
//
//	@Check
//	def checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.name.charAt(0))) {
//			warning('Name should start with a capital', 
//					MyDslPackage.Literals.GREETING__NAME,
//					INVALID_NAME)
//		}
//	}
	@Check
	def checkItemAttribute(Item item) {

		item.attributes.forEach [
			if (it instanceof Health)
				error("Items do not have health try durability instead ", MyDslPackage.eINSTANCE.item_ItemType)

			if (it instanceof CarryCapacity)
				error("Items does not have carry capacity ", MyDslPackage.eINSTANCE.item_ItemType)
			if (it instanceof Escapeable)
				error("Items does not have escapeable", MyDslPackage.eINSTANCE.item_ItemType)
		]
	}
	@Check
	def checkPlayerAttribute(Player player) {

		player.attributes.forEach [
			if (it instanceof Weight)
				error("Player does not have weight ", MyDslPackage.eINSTANCE.player_PlayerType)
			if (it instanceof Durability)
				error("Player does not have Durability", MyDslPackage.eINSTANCE.player_PlayerType)
			if (it instanceof Escapeable)
				error("Player does not have Escapeable", MyDslPackage.eINSTANCE.player_PlayerType)
		]
	}
	@Check
	def checkNPCAttribute(NPC npc) {

		npc.attributes.forEach [
			if (it instanceof Weight)
				error("NPC does not have weight ", MyDslPackage.eINSTANCE.NPC_NpcType)
			if (it instanceof Durability)
				error("NPC does not have Durability", MyDslPackage.eINSTANCE.NPC_NpcType)
			if (it instanceof CarryCapacity)
				error("NPC does not have CarryCapacity", MyDslPackage.eINSTANCE.NPC_NpcType)
		]
	}

}
