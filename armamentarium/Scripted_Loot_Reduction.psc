Scriptname Armamentarium:Scripted_Loot_Reduction extends ActiveMagicEffect

import Utility

int tickTimer = 1
ObjectReference[] actor_array = None
ObjectReference[] container_array = None

Event OnEffectStart(actor akTarget, actor akCaster)
	Log("OnEffectStart","Starting...")
	Log("OnEffectStart","ReductionProbability : " + ReductionProbability.Value)
	Log("OnEffectStart","Radius               : " + Radius.Value)
	Log("OnEffectStart","TickLength           : " + TickLength.Value)
	StartTimer(TickLength.Value as Int, tickTimer) ; start updating
EndEvent

Event OnTimer(int tickTimer)
	Log("OnTimer","Tick!")
	If GameStateIsValid()
		
		int i = 0
		Bool bBreak = False

		; look for actors near the player
		While (i < SLR_Bodies_List.GetSize()) && !bBreak
			Form this_keyword = SLR_Bodies_List.GetAt(i)
			actor_array = PlayerRef.FindAllReferencesWithKeyword(this_keyword, Radius.Value)
			If actor_array != None
				If actor_array.Length > 0
					Log("OnTimer","FOUND " + actor_array.Length + " actors with keyword: " + this_keyword)
					ProcessActorArray(actor_array)
				EndIf
			EndIf
			i += 1
		EndWhile

		; look for containers near the player
		container_array = PlayerRef.FindAllReferencesOfType(SLR_Containers_List, Radius.Value)
		If container_array != None
			If container_array.Length > 0
				Log("OnTimer","FOUND " + container_array.Length + " containers")
				ProcessContainerArray(container_array)
			EndIf
		EndIf
	EndIf

	Log("OnTimer","Finished, starting timer for next cycle...")
	StartTimer(TickLength.Value as Int, tickTimer) ; keep updating
EndEvent

; -----------------------------------------------------------------------------
; FUNCTIONS
; -----------------------------------------------------------------------------

; Log
Function Log(String asFunction = "", String asMessage = "") DebugOnly
	Debug.Trace("Scripted Loot Reduction->" + asFunction + ": " + asMessage, 0)
EndFunction

; Old Log()
; Function Log(String asFunction = "", String asMessage = "") DebugOnly
; 	Debug.TraceSelf(Self, asFunction, asMessage)
; EndFunction

; Return true if any exit condition met
Bool Function GameStateIsValid()
	Return !Utility.IsInMenuMode() && Game.IsMovementControlsEnabled() && !Game.IsVATSPlaybackActive()
EndFunction

; Return true if all conditions are met - fireundubh's function!
Bool Function ItemCanBeProcessed(ObjectReference akItem)
	Return akItem.Is3DLoaded() && !akItem.IsDisabled() && !akItem.IsDeleted() && !akItem.IsDestroyed() && !akItem.IsActivationBlocked()
EndFunction

Function ProcessActorArray(ObjectReference[] akArray)
	Int i = 0
	Bool bBreak = False
	While (i < akArray.Length) && !bBreak
		ObjectReference this_actor = akArray[i]
		If !GameStateIsValid()
			Log("ProcessActorArray","!GameStateIsValid(), BREAKING")
			bBreak = True
		EndIf
		If !bBreak
			If this_actor != None
				If ItemCanBeProcessed(this_actor)
					Actor this_actor_as_actor = this_actor As Actor
					If (this_actor_as_actor.GetKiller() != None)
						If !this_actor.HasKeyword(SLR_Container_Was_Processed)
							Log("ProcessActorArray","actor " + this_actor + " was not already processed, let's ProcessContainer()...")
							ProcessContainer(this_actor, SLR_Formlist_Actor)
							;Log("ProcessContainer","Finished with " + akContainer + ", adding keyword: SLR_Container_Was_Processed.")
							this_actor.AddKeyword(SLR_Container_Was_Processed)
							this_actor.Additem(SLR_Loot_Reduced_Token, 1, True)
						EndIf 
					EndIf
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

Function ProcessContainerArray(ObjectReference[] akArray)
	Int i = 0
	Bool bBreak = False
	While (i < akArray.Length) && !bBreak
		ObjectReference this_container = akArray[i]
		If !GameStateIsValid()
			Log("ProcessContainerArray","!GameStateIsValid(), BREAKING")
			bBreak = True
		EndIf
		If !bBreak
			If this_container != None
				If ItemCanBeProcessed(this_container)
					If !this_container.HasKeyword(SLR_Container_Was_Processed)
						Log("ProcessContainerArray","container " + this_container + " was not already processed, let's ProcessContainer()...")
						ProcessContainer(this_container, SLR_Formlist_Container)
						;Log("ProcessContainer","Finished with " + akContainer + ", adding keyword: SLR_Container_Was_Processed.")
						this_container.AddKeyword(SLR_Container_Was_Processed)
						this_container.Additem(SLR_Loot_Reduced_Token, 1, True)
					EndIf 
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction


Function ProcessContainer(ObjectReference akContainer, Formlist akFilter)
	If (akContainer != None)
		Int filter_pos = 0
		Bool bBreak = False
		While (filter_pos < akFilter.GetSize()) && !bBreak
			If !GameStateIsValid()
				Log("ProcessContainer","!GameStateIsValid(), BREAKING")
				bBreak = True
			EndIf
			Formlist this_filter = akFilter.GetAt(filter_pos) as Formlist
			RollToRemoveItems(akContainer, this_filter)
			filter_pos += 1
		EndWhile
	EndIf
EndFunction

Function RollToRemoveItems(ObjectReference akContainer, Formlist akItems)
	If GameStateIsValid()
		If RandomFloat(0.0, 1.0) < ReductionProbability.Value ; percentage roll to remove this item (actually list of items)!
			Log("RollToRemoveItems","Success! Removing " + akContainer.GetItemCount(akItems) + " items in " + akItems + " from container" + akContainer)
			akContainer.RemoveItem(akItems, -1, True, None)
		EndIf
	EndIf
EndFunction

Function TryToRemoveItem(ObjectReference akContainer, Form akItem)
	If GameStateIsValid()
		If RandomFloat(0.0, 1.0) < ReductionProbability.Value ; percentage roll to remove this item!
			akContainer.RemoveItem(akItem, -1, True, None)
			;akContainer.Additem(SLR_Loot_Reduced_Token, 1, True)
		EndIf
	EndIf
EndFunction

; -----------------------------------------------------------------------------
; PROPERTIES
; -----------------------------------------------------------------------------


; Actors
Actor Property PlayerRef Auto

; Formlists
Formlist Property SLR_Bodies_List Auto
Formlist Property SLR_Containers_List Auto
Formlist Property SLR_Formlist_Container Auto
Formlist Property SLR_Formlist_Actor Auto

; Globals
GlobalVariable Property ReductionProbability Auto Const
GlobalVariable Property Radius Auto Const
GlobalVariable Property TickLength Auto Const

; Misc.
Book Property SLR_Loot_Reduced_Token Auto
Keyword Property SLR_Container_Was_Processed Auto