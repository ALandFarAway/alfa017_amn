////////////////////////////////////////////////////////////////////////////////
//
//  System Name : ALFA Core Rules
//     Filename : gui_alfa_firstaid
//      Version : 0.1
//         Date : 8/20/2007
//       Author : AcadiusLost
//
//  Local Variable Prefix : ACR_HEAL
//
//  Description
//  This script processes player attempts to use the Heal Skill, on themselves
//  or on others.  The inital and main purpose is to allow stabilzation attempts
//  as DC15 Heal checks.  Later we may add cure disease, cure poison, and longterm
//  care handling to this code.
//       Basically just a gui-enabled version of abr_it_firstaid.nss
//
//  Revision History
//  8/20/2007 AcadiusLost: Inception
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Includes ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#include "acr_death_i"
#include "acr_resting_i"


////////////////////////////////////////////////////////////////////////////////
// Constants ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Structures //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Function Prototypes /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//!  Handled the bandaging check, wrapped into a function so it can be forced
//!   into an AssignCommand on the action Queue.
void _playerApplyFirstAid(object oHelper, object oDying, int nDC);

////////////////////////////////////////////////////////////////////////////////
// Function Definitions ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void main()
{
    object oUser = OBJECT_SELF; 
	object oPatient = GetPlayerCurrentTarget(oUser);
	
	int nFirstAidDC = 15;
	
	if (oPatient == OBJECT_INVALID)
	{
	    SendMessageToPC(oUser, "Nothing there to apply first aid to.");
		return;
	}
	// Modify DC for Healing Kit or other circumstance bonus.

	// Modify DC for Self Sufficient feat, if present.
	if (GetHasFeat(FEAT_SELF_SUFFICIENT, oUser)) 
	{ 
	    nFirstAidDC = nFirstAidDC - 2; 
    }
    AssignCommand(oUser, ActionMoveToObject(oPatient, TRUE));
    AssignCommand(oUser, ActionDoCommand(_playerApplyFirstAid(oUser, oPatient, nFirstAidDC)));
}


void _playerApplyFirstAid(object oHelper, object oDying, int nDC) {

    // determine if the target is in need of First Aid
    if (GetCurrentHitPoints(oDying) <= 0)
	{
	    if (ACR_GetIsPlayerStabilized(oDying)) 
		{
		    SendMessageToPC(oHelper, GetName(oDying)+" is already stable.");

	    } else if (GetIsSkillSuccessful(oHelper, SKILL_HEAL, nDC))
		{ 
			ACR_StabilizePlayer(oDying);
			SendMessageToPC(oHelper, "You successfully bind "+GetName(oDying)+"'s wounds.");
			SendMessageToPC(oDying, "Your bleeding is staunched by "+GetName(oHelper)+".");
		} else {
		    SendMessageToPC(oHelper, "You were unable to stop "+GetName(oDying)+"'s bleeding.");
			SendMessageToPC(oDying, GetName(oHelper)+" has tried unsuccessfully to bind your wounds.");
	    } 
	} else {
	//  FIX ME <--------- should add other uses of heal here
	    SendMessageToPC(oHelper, GetName(oDying)+" doesn't seem to be in need of first aid.");
	}

return;
}