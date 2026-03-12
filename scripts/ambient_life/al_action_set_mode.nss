void main()
{
    object oNpc = OBJECT_SELF;
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sMode = GetLocalString(oNpc, "al_action_mode_value");
    DeleteLocalString(oNpc, "al_action_mode_value");
    SetLocalString(oNpc, "al_mode", sMode);
}
