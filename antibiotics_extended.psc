Scriptname AntibioticsExtendedScript extends ObjectReference

import Utility
Actor Property PlayerREF Auto
Quest Property MyQuest Auto
Int Property TotalDuration Auto
Int Property TickLength Auto
Int Property ElapsedDuration Auto
Float Property ProbabilityPerTick Auto

Event OnInit()

	; start a timer to cancel the script at the end of the duration
	; Function StartTimer(float TotalDuration) native

	; Start updating
	RegisterForSingleUpdate(TickLength)

EndEvent

Event OnUpdate()
	TotalDuration = TotalDuration + TickLength
	If RandomFloat(0.0, 1.0) < ProbabilityPerTick
		; then cure disease!
		___.Cast(PlayerREF)
		; maybe a message box 'You feel better!'?
	EndIf

	If ElapsedDuration < TotalDuration

		RegisterForSingleUpdate(TickLength)
	EndIf

EndEvent

; Event OnTriggerEnter(ObjectReference akActionRef)
; 	If akActionRef == Game.GetPlayer()
; 		MyQuest.SetStage(StageToSet)
; 	EndIf
; EndEvent