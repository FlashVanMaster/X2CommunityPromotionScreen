class NewPromotionScreenByDefault_PromotionScreenListener extends UIScreenListener;

var StateObjectReference StoredUnitRef;

// This event is triggered after a screen is initialized. This is called after
// the visuals (if any) are loaded in Flash.
event OnInit(UIScreen Screen)
{			
	local UIArmory_Promotion OriginalPromotionUI;
	local UIArmory_PromotionHero CustomHeroPromotionUI;
	local StateObjectReference UnitBeingPromoted;
	local UIAfterAction AfterActionUI;
			
	if (UIArmory_Promotion(Screen) == none || UIArmory_PromotionHero(Screen) != none || UIArmory_PromotionPsiOp(Screen) != none)
	{		
		return;		
	}
		
	//Don't block the tutorial
	if(!class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory') )
	{		
		return;
	}
		
	//Remove original screen	
	Screen.Movie.Stack.Pop(Screen);	

	//Convert Values
	OriginalPromotionUI = UIArmory_Promotion(Screen);
	UnitBeingPromoted = OriginalPromotionUI.UnitReference;
	StoredUnitRef = UnitBeingPromoted;

	//Create new screen		
	CustomHeroPromotionUI = Screen.Movie.Pres.Spawn(class'UIArmory_PromotionHero' );		
	Screen.Movie.Stack.Push(CustomHeroPromotionUI, Screen.Movie.Pres.Get3DMovie());	
	CustomHeroPromotionUI.InitPromotion(UnitBeingPromoted);

	//Fix Post mission walkup 		
	AfterActionUI = UIAfterAction(`SCREENSTACK.GetFirstInstanceOf(class'UIAfterAction'));
	
	if( AfterActionUI != none )
	{
		//AfterActionUI.MovePawns();
		MovePawns(AfterActionUI, UnitBeingPromoted);
	}
}

function MovePawns(UIAfterAction AfterActionUI,StateObjectReference UnitBeingPromoted)
{	
	local int i;
	local XComUnitPawn UnitPawn, GremlinPawn;
	local PointInSpace PlacementActor;

	for(i = 0; i < AfterActionUI.XComHQ.Squad.Length; ++i)
	{
		if(AfterActionUI.XComHQ.Squad[i] == UnitBeingPromoted)
		{
			PlacementActor = AfterActionUI.GetPlacementActor(AfterActionUI.GetPawnLocationTag(AfterActionUI.XComHQ.Squad[i], GetPromotionBlueprintTag(AfterActionUI,UnitBeingPromoted) ) );
			UnitPawn = AfterActionUI.UnitPawns[i];

			if(UnitPawn != none && PlacementActor != none)
			{						
				UnitPawn.SetLocation(PlacementActor.Location);
				GremlinPawn = `HQPRES.GetUIPawnMgr().GetCosmeticPawn(eInvSlot_SecondaryWeapon, UnitPawn.ObjectID);
				if(GremlinPawn != none)
					GremlinPawn.SetLocation(PlacementActor.Location);
			}

			continue;
		}
		
		PlacementActor = AfterActionUI.GetPlacementActor(AfterActionUI.GetPawnLocationTag(AfterActionUI.XComHQ.Squad[i], AfterActionUI.m_strPawnLocationSlideawayIdentifier));
		UnitPawn = AfterActionUI.UnitPawns[i];

		if(UnitPawn != none && PlacementActor != none)
		{						
			UnitPawn.SetLocation(PlacementActor.Location);
			GremlinPawn = `HQPRES.GetUIPawnMgr().GetCosmeticPawn(eInvSlot_SecondaryWeapon, UnitPawn.ObjectID);
			if(GremlinPawn != none)
				GremlinPawn.SetLocation(PlacementActor.Location);
		}
	}
	
}

simulated function string GetPromotionBlueprintTag(UIAfterAction AfterActionScreen, StateObjectReference UnitRef)
{
	local int i;
	local XComGameState_Unit UnitState;

	for(i = 0; i < AfterActionScreen.XComHQ.Squad.Length; ++i)
	{
		if(AfterActionScreen.XComHQ.Squad[i].ObjectID == UnitRef.ObjectID)
		{
			UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AfterActionScreen.XComHQ.Squad[i].ObjectID));
			
			if (UnitState.IsGravelyInjured())
			{
				return AfterActionScreen.UIBlueprint_PrefixHero_Wounded $ i;
			}
			else
			{
				return AfterActionScreen.UIBlueprint_PrefixHero $ i;
			}						
		}
	}

	return "";
}

event OnReceiveFocus(UIScreen Screen)
{		
	local UIAfterAction AfterActionScreen;
	local int i;

	if(UIAfterAction(Screen) != none )
	{		
		return;		
	}

	AfterActionScreen = UIAfterAction(`SCREENSTACK.GetFirstInstanceOf(class'UIAfterAction'));
	
	if( AfterActionScreen == none )
	{
		return;
	}
	
	for(i = 0; i < AfterActionScreen.XComHQ.Squad.Length; ++i)
	{
		if(AfterActionScreen.XComHQ.Squad[i].ObjectID == StoredUnitRef.ObjectID)
		{
			`HQPres.CAMLookAtNamedLocation(GetPromotionBlueprintTag(AfterActionScreen,StoredUnitRef), `HQINTERPTIME);	
		}

	}	
}

event OnLoseFocus(UIScreen Screen);
event OnRemoved(UIScreen Screen);

defaultproperties
{	
	//Listening to any Promotion Screens
	ScreenClass = none;
}