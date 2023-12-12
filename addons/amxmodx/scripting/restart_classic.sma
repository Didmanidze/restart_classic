#include <amxmodx>
#include <reapi>

#define CREATE_CONFIG //Автоматическое создание конфига в configs/plugins

enum _:COLORS{
    RGB[3]
}

enum _:CVARS
{
    RR_ROUNDS[16],
    RR_ROUND_DELAY,
    RR_TYPE_MSG,
    RR_RGB_D_HUD[32],
    Float:RR_POS_X_D_HUD,
    Float:RR_POS_Y_D_HUD,
    Float:RR_HOLDTIME_D_HUD
}

new CvarData[CVARS], g_SyncMsg, g_Colors[COLORS];

public plugin_init()
{
    register_plugin("restart classic", "2.1", "RockTheStreet/RedFoxxx");
	
    RegisterHookChain(RG_CSGameRules_RestartRound, "CSGRules_RestartRound_Post", .post = true);

    g_SyncMsg = CreateHudSyncObj();

    RegisterCvars();

    #if defined CREATE_CONFIG
    AutoExecConfig(true, "rr_classic");
    #endif
}

RegisterCvars()
{
    bind_pcvar_num(create_cvar(
        "rr_rounds",
        "30",
        FCVAR_NONE,
        "Здесь определяете сколько раундов будете играть, и через сколько произойдет рестарт игры"),
        CvarData[RR_ROUNDS]
    );

    bind_pcvar_num(create_cvar(
        "rr_round_delay",
        "1",
        FCVAR_NONE,
        "Число рестартов игры"),
        CvarData[RR_ROUND_DELAY]
    );

    bind_pcvar_num(create_cvar(
        "rr_type_msg",
        "1",
        FCVAR_NONE,
        "Тип оповещания^n\
        0 - Отключено^n\
        1 - В чат^n\
        2 - HUD^n\
        3 - DHUD"),
        CvarData[RR_TYPE_MSG]
    );

    bind_pcvar_string(create_cvar(
        "rr_rgb_d_hud",
        "255 255 255",
        FCVAR_NONE,
        "Цвет D/HUD оповещания"),
        CvarData[RR_RGB_D_HUD],
        charsmax(CvarData[RR_RGB_D_HUD])
    );

    bind_pcvar_float(create_cvar(
        "rr_pos_x_d_hud",
        "-1.0",
        FCVAR_NONE,
        "Позиция X координаты D/HUD"),
        CvarData[RR_POS_X_D_HUD]
    );

    bind_pcvar_float(create_cvar(
        "rr_pos_y_d_hud",
        "0.25",
        FCVAR_NONE,
        "Позиция Y координаты D/HUD"),
        CvarData[RR_POS_Y_D_HUD]
    );

    bind_pcvar_float(create_cvar(
        "rr_holdtime_d_hud",
        "7.0",
        FCVAR_NONE,
        "Время сообщения на экране"),
        CvarData[RR_HOLDTIME_D_HUD]
    );


    new szColors[32], iColors;
    
    if(CvarData[RR_RGB_D_HUD][0] != EOS)
        while(argbreak(CvarData[RR_RGB_D_HUD], szColors, charsmax(szColors), CvarData[RR_RGB_D_HUD], charsmax(CvarData[RR_RGB_D_HUD])) != -1)
            g_Colors[RGB][iColors++] = str_to_num(szColors);
}

public CSGRules_RestartRound_Post()
{
    new rounds_played = get_member_game(m_iTotalRoundsPlayed);
 
    if (rounds_played >= CvarData[RR_ROUNDS])  {
        rg_swap_all_players();
        server_cmd("sv_restartround %d", CvarData[RR_ROUND_DELAY])
    }else{
        if(CvarData[RR_TYPE_MSG] <= 0){
            return;
        }

        if(CvarData[RR_TYPE_MSG] == 1){
            client_print_color(0, print_team_default, "^4* ^1Рестарт через ^4%d ^1раунд(а,ов)", CvarData[RR_ROUNDS] - rounds_played);
            return;
        }

        if(CvarData[RR_TYPE_MSG] == 2){
            set_hudmessage(.red = g_Colors[RGB][0], .green = g_Colors[RGB][1], .blue = g_Colors[RGB][2], .x = CvarData[RR_POS_X_D_HUD], .y = CvarData[RR_POS_Y_D_HUD], .effects = 1, .holdtime = CvarData[RR_HOLDTIME_D_HUD]);
            ShowSyncHudMsg(0, g_SyncMsg, "Рестарт через %d раунд(а.ов)", CvarData[RR_ROUNDS] - rounds_played);
            return;
        }

        if(CvarData[RR_TYPE_MSG] >= 3){
            set_hudmessage(.red = g_Colors[RGB][0], .green = g_Colors[RGB][1], .blue = g_Colors[RGB][2], .x = CvarData[RR_POS_X_D_HUD], .y = CvarData[RR_POS_Y_D_HUD], .effects = 1, .holdtime = CvarData[RR_HOLDTIME_D_HUD]);
            show_dhudmessage(0, "Рестарт через %d раунд(а.ов)", CvarData[RR_ROUNDS] - rounds_played);
            return;
        }
    }
}