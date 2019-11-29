ScriptName Armamentarium:DamageThresholdApplyGloballyEffect extends ActiveMagicEffect

Int tick_timer = 1
Float elapsed_duration
ObjectReference[] actor_array = None

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Log("OnEffectStart","Starting...")
	Log("OnEffectStart","DT Multiplier  : " + DamageThresholdMult.Value)
	Log("OnEffectStart","Radius         : " + Radius.Value)
  Log("OnEffectStart","TickLength     : " + TickLength.Value)
	Self.StartTimer(TickLength.Value, tick_timer)
EndEvent

Event OnTimer(int tick_timer)
  Log("OnTimer","Tick!")

  elapsed_duration += TickLength.Value ; obviously, script lag could cause this to be wildly innaccurate.
	If (elapsed_duration < MaxDuration.Value)
		Self.StartTimer(TickLength.Value, tick_timer)
  EndIf
  UpdateAll()
EndEvent

; probably also need an event for exiting the pipboy, to properly keep up with chems, etc.
; this could target only the player...

; -----------------------------------------------------------------------------
; FUNCTIONS
; -----------------------------------------------------------------------------

; Log
Function Log(String asFunction = "", String asMessage = "") DebugOnly
	Debug.Trace("DamageThresholdApplyGlobally->" + asFunction + ": " + asMessage, 0)
EndFunction

Bool Function GameStateIsValid()
	Return !Utility.IsInMenuMode() && Game.IsMovementControlsEnabled() && !Game.IsVATSPlaybackActive()
EndFunction

; Return true if all conditions are met - fireundubh's function!
Bool Function ItemCanBeProcessed(ObjectReference akItem)
	Return akItem.Is3DLoaded() && !akItem.IsDisabled() && !akItem.IsDeleted() && !akItem.IsDestroyed() && !akItem.IsActivationBlocked()
EndFunction

Function UpdateAll()
  If GameStateIsValid()
    actor_array = PlayerRef.FindAllReferencesWithKeyword(ActorTypeNPCKeyword, Radius.Value) ; I'm hoping that this finds all the relevant actors.
    If actor_array != None
      If actor_array.Length > 0
        Log("UpdateAll","FOUND " + actor_array.Length + " references with keyword: " + ActorTypeNPCKeyword)
        ProcessActorArray(actor_array)
      EndIf
    EndIf
  EndIf
EndFunction

Function ProcessActorArray(ObjectReference[] akArray)
  Log("ProcessActorArray","starting...")
  Int i = 0
	Bool bBreak = False
	While (i < akArray.Length) && !bBreak
		ObjectReference this_actor = akArray[i]
		If !GameStateIsValid()
			Log("ProcessActorArray","!GameStateIsValid(), breaking")
			bBreak = True
		EndIf
		If !bBreak
			If this_actor != None
				If ItemCanBeProcessed(this_actor)
					Actor this_actor_as_actor = this_actor As Actor
					If (this_actor_as_actor.GetKiller() == None) ; if the actor is still alive--this might also hit preplaced dead bodies. I'm hoping this won't be a problem.
						If !this_actor_as_actor.HasKeyword(DTAG_Do_Not_Apply)
							ProcessActor(this_actor_as_actor)
						EndIf 
					EndIf
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

Function ProcessActor(Actor akActor)
  ; Log("ProcessActorArray", "Actor: " + akActor)
  Float Dr = akActor.GetValue(DamageResistAV) ; get the actor's damage resistance. DTF only affects physical right now...
  Int Dt = (akActor.GetValue(DamageResistAV) * DamageThresholdMult.Value) as Int ; documentation says this is faster than floor, and round doesn't appear to even exist... wtf?
  akActor.SetValue(DamageThresholdAV, Dt) ; set the actor's DT to the calculated amount
  Log("ProcessActor", "Actor: " + akActor + ", DR: " + Dr + ", DT: " + Dr)
EndFunction

; -----------------------------------------------------------------------------
; PROPERTIES
; -----------------------------------------------------------------------------

; Actors
Actor Property PlayerRef Auto

; Globals
GlobalVariable Property DamageThresholdMult Auto Mandatory
GlobalVariable Property Radius Auto Mandatory
GlobalVariable Property TickLength Auto Mandatory
GlobalVariable Property MaxDuration Auto Mandatory

; Misc
ActorValue property DamageThresholdAV Auto Mandatory
ActorValue property DamageResistAV Auto Mandatory
; ActorValue property EnergyResistAV
Keyword property ActorTypeNPCKeyword Auto Const Mandatory
Keyword property DTAG_Do_Not_Apply Auto Mandatory
Message Property DTAG_mesg_OnInit Auto Const mandatory ; const?!