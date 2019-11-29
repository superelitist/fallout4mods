;/ Decompiled by Champollion V1.0.6
PEX format v3.9 GameID: 2
Source   : C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\Scripts\Source\User\Armamentarium\AntibioticsExtendedEffect.psc
Modified : 2019-07-11 20:20:18
Compiled : 2019-07-11 20:21:54
User     : superelitist
Computer : TYRIAN-DESKTOP
/;
ScriptName AntibioticsExtendedEffect extends ActiveMagicEffect

;-- Properties --------------------------------------
Actor Property PlayerREF Auto
int Property MaxDuration Auto
int Property TickLength Auto
float Property ProbabilityPerTick Auto
Spell Property AntibioticEffect Auto
Message Property Antibiotics_Extended_mesg_OnInit Auto Const mandatory
Message Property Antibiotics_Extended_mesg_OnTimer Auto Const mandatory
Message Property Antibiotics_Extended_mesg_OnCure Auto Const mandatory
Potion Property HC_Antibiotics_SILENT_SCRIPT_ONLY Auto

;-- Variables ---------------------------------------
int tickTimer = 1
int elapsed_duration

;-- Functions ---------------------------------------

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Self.StartTimer(TickLength as float, tickTimer)
EndEvent

Event OnTimer(int tickTimer)
	elapsed_duration += TickLength
	If (Utility.RandomFloat(0, 1) < ProbabilityPerTick)
		PlayerREF.EquipItem(HC_Antibiotics_SILENT_SCRIPT_ONLY as Form, False, True)
		Antibiotics_Extended_mesg_OnCure.Show(0, 0, 0, 0, 0, 0, 0, 0, 0)
	EndIf
	If (elapsed_duration < MaxDuration)
		Self.StartTimer(TickLength as float, tickTimer)
	EndIf
EndEvent
