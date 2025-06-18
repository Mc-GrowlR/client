--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ActMessageTable = 
{
    CompoundItem                         = "G_CompoundItem", -- 合成

    Bag                         = "1", -- 背包
    StarsChallengeInstance      = "2", -- 三星试炼
    PersonBossChallengeInstance	= "3", --个人BOSS挑战
}

-------------------------------------------下面代码勿删勿删 ---------------------------------------------------
-------------------------------------------下面代码勿删勿删 ---------------------------------------------------
-------------------------------------------下面代码勿删勿删 ---------------------------------------------------
data = 
{
    {
        q_id = 1, 
        q_fix_rewards = 
        {
            ncs = 1, 
            num = 5, 
            id = 8002 
        },
        q_need_activepoint = 100, 
        q_box_num =10, 
        q_name = '1级功勋宝箱', 
        q_index = 1, 
    },
    {
        q_id = 2, 
        q_fix_rewards = 
        {
            ncs = 1,
            num = 5, 
            id = 8002,
        },
        q_need_activepoint = 200, 
        q_box_num = 10, 
        q_name = '1级功勋宝箱', 
        q_index = 2,
    },
    {
        q_activitie_id = 15003, 
        q_id = 3,
        q_fix_rewards = 
        {
            ncs = 1, 
            num = 1, 
            id = 20009, 
            losttime = 86400
        },
        q_neecd_aetivepoint = 400, 
        q_box_num = 10, 
        q_name = ' 1级功勋宝箱', 
        q_index = 3,
    },
    {
        q_id = 4,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 1, 
                id = 8080
            }
        }, 
        q_need_activepoint = 600, 
        q_box_nuni =10, 
        q_name = '1级功勋宝箱', 
        q_index = 4
    },
    {
        q_id = 5,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 800, 
        q_box_num = 10, 
        q_name = '1级功勋宝箱', 
        q_index = 5
    },
    {
        q_show_activepoint = 800, 
        q_id = 6,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 1600, 
        q_box_num = 10, 
        q_name = ' 1级功勋宝箱', 
        q_index = 6
    },
    {
        q_show_activepoint = 800, 
        q_id = 7,
        q_fix_rewards = 
        {
            ncs = 1, 
            num = 4,
            id = 8012
        }
    },
    {
        q_need_activepoint = 2400,
        q_box_num = 10,
        q_name = '1级功勋宝箱',
        q_index = 7
    },
    {
        q_show_activepoint = 800,
        q_id = 8, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4,
                id = 8012
            }
        },
        q_need_activepoint = 3200,
        q_box_num = 10,
        q_name = '1级功勋宝箱',
        q_index = 8,
    },
    {
        q_id = 10, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002
            }
        },
        q_noed_activcpoint = 200,
        q_box_num = 10, 
        q_name = ' 2级功勋宝箱',
        q_index = 1,
        q_grade = 1
    },
    {
        q_id = 11,
        q_fix_rewards = 
        {
            {
                ncs = 1.,
                num = 5,
                id = 8002
            },
        },
        q_noed_activcpoint = 400,
        q_box_num = 10,
        q_name = '2级功勋宝箱',
        q_index = 2,
        q_grade = 1,
    },
    {
        q_activitie_id = 15003,
        q_id = 12,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 1, 
                id = 20009, 
                losttime = 86400 
            }
        },
        q_need_activepoint = 800, 
        q_box_num =10, 
        q_name = ' 2级功勋宝箱', 
        q_index = 3,
        q_grade = 1
    },
    {
        q_id = 13,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 8080
            }
        },
        q_need_activepoint = 1200, 
        q_box_num = 10, 
        q_name = '2级功勋宝箱', 
        q_index = 4,
        q_grade = 1
    },
    {
        q_id = 14,
        q_fix_rewards = 
        {
            {

            }
        },
        q_need_activepoint = 1600, 
        q_box_nuifr = 10,
        q_name = ' 2级功勋宝箱', 
        q_index = 5,
        q_grade = 1 
    }, 
    {
        q_show_activepoint = 1600, 
        q_id = 15,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 4, 
                id = 8012 
            }
        }, 
        q_need_activepoint = 3200, 
        q_box_num =10, 
        q_name = ' 2级功勋宝箱', 
        q_index = 6, 
        q_grade = 1
    },
    {
        q_show_activepoint = 1600, 
        q_id = 16,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 4, 
                id = 8012 
            }
        },
        q_need_activepoint = 4800, 
        q_box_num = 10, 
        q_name = ' 2级功勋宝箱', 
        q_index = 7,
        q_grade = 1
    },
    {
        q_show_activepoint = 1600, 
        q_id = 17,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 640, 
        q_box_num = 10, 
        q_name = ' 2级功勋宝箱',
        q_index = 8,
        q_grade = 1
    },
    {
        q_id = 19,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 5, 
                id = 8002
            }
        },
        q_need_activepoint = 300, 
        q_box_num = 10, 
        q_name = ' 3级功勋宝箱', 
        q_index = 1, 
        q_grade = 2
    },
    {
        q_id = 20, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5, 
                id = 8002
            }
        },
        q_need_activepoint = 600, 
        q_box_num =10,
        q_name = ' 3级功勋宝箱', 
        q_index = 2,
        q_grade = 2
    },
    {
        q_activitie_id = 15003,
        q_id = 21,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 20009, 
                losttime = 86400 
            }
        },
        q_need_activepoint = 1200, 
        q_box_num = 10,
        q_name = ' 3级功勋宝箱', 
        q_index = 3,
        q_grade = 2, 
    },   
    {
        q_id = 22, 
        q_fix_rewards =
        {
            { 
                ncs = 1, 
                num = 1, 
                id = 8080,
            }
        },
        q_need_activepoint = 1800,
        q_box_num = 10, 
        q_name = '3级功勋宝箱', 
        q_index = 4,
        q_grade = 2
    },
    {
        q_id = 23, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012 
            }
        },
        q_need_activepoint = 2400, 
        q_box_num = 10, 
        q_name = ' 3级功勋宝箱', 
        q_index = 5,
        q_grade = 2
    },
    {
        q_show_activepoint = 2400, 
        q_id = 24,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 4800, 
        q_box_num = 10,
        q_name = ' 3级功勋宝箱',
        q_index = 6,
        q_grade = 2
    },
    {
        q_show_activepoint = 2400, 
        q_id = 25,
        q_fix_rewards = 
        {
            {
            ncs = 1,
            num = 4,
            id = 8012
            }
        },
        q_need_activepoint = 7200,
        q_box_num = 10,
        q_name = ' 3级功勋宝箱',
        q_index = 7,
        q_grade = 2
    },
    {
        q_show_activepoint = 2400,
        q_id = 26,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4,
                id = 8012
            }
        },
        q_need_activepoint = 9600,
        q_box_num =10,
        q_name = ' 3级功勋宝箱',
        q_index = 8,
        q_grade = 2
    },
    {
        q_id = 28,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002
            }
        },
        q_need_activepoint = 400,
        q_box_num = 10,
        q_name = '4级功勋宝箱',
        q_index = 1,
        q_grade = 3
    },
    {
        q_need_activepoint = 3200,
        q_box_num = 10,
        q_name = ' 2级功勋宝箱',
        q_index = 6,
        q_grade = 1
    },
    {
        q_show_activepoint = 1600,
        q_id = 16,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012 
            }
        }, 
        q_need_activepoint = 4800, 
        q_box_num = 10, 
        q_name = ' 2级功勋宝箱', 
        q_indcx = 7, 
        q_grade = 1
    },
    {
        q_show_activepoint = 1600, 
        q_id = 17,
        q_fix_rewards = 
        {

        },
        q_need_activepoint = 6400, 
        q_box_num =10, 
        q_name = ' 2级功勋宝箱', 
        q_index = 8,
        q_grade = 1
    },
    {
        q_id = 19,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5, 
                id = 8002
            }
        },
        q_need_activepoint = 300, 
        q_box_num = 10, 
        q_name = ' 3级功勋宝箱', 
        q_index = 1,
        q_grade = 2
    },
    {
        q_id = 20,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5, 
                id = 8002
            }
        },
        q_need_activopoint = 600, 
        q_box_num = 10,
        q_name = ' 3级功勋宝箱',
        q_index = 2, 
        q_grade = 2
    },
    {
        q_activitie_id = 15003, 
        q_id = 21,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 20009,
                losttime = 86400 
            }
        },
        q_need_activopoint = 1200, 
        q_box_num = 10, 
        q_name = ' 3级功勋宝箱', 
        q_index = 3,
        q_grade = 2
    },
    {
        q_id = 22,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 8080
            }
        },
        q_need_activopoint = 1800, 
        q_box_num =10,
        q_name = ' 3级功勋宝箱', 
        q_index = 4,
        q_grade = 2
    },
    {
        q_id = 23,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            } 
        },
        q_need_activopoint = 2400, 
        q_box_num = 10,
        q_name ='3 钗功勋宝箱',
        q_index = 5,
        q_grade = 2
    },
    {
        q_show_activepoint = 2400,
        q_id = 24,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4,
                id = 8012
            }
        },
        q_need_activopoint = 4800,
        q_box_num = 10,
        q_name = ' 3级功勋宝箱',
        q_index = 6,
        q_grade = 2
    },
    {
        q_show_activepoint = 2400,
        q_id = 25,	
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4,
                id = 8012
            }
        },
        q_need_activepoint = 7200,
        q_box_num = 10,
        q_name = ' 3级功勋宝箱',
        q_index = 7,
        q_grade = 2
    },
    {
        q_show_activepoint = 2400,
        q_id = 26,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4,
                id = 8012
            }
        },
        q_need_activepoint = 9600,			
        q_box_num = 10,
        q_name = ' 3级功勋宝箱',
        q_index = 8, 
        q_grade = 2
    },
    {
        q_id = 28,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5, id = 8002
            }
        },
        q_need_activopoint = 400, 
        q_box_num = 10, 
        q_name = '4级功勋宝箱', 
        q_index = 1,
        q_grade = 3
    },
    {
        q_id = 29, 
        q_fix_rewards = 
        {
            {
                ncs = 1, num = 5, id = 8002
            }
        },
        q_need_activepoint = 800, 
        q_box_num = 10, 
        q_name = '4级功勋宝箱', 
        q_index = 2,
        q_grade = 3
    },
    {
        q_activitic_id = 15003, 
        q_id = 30,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 20009, 
                losttime = 86400 
            }
        },
        q_need_activepoint = 1600, 
        q_box_num = 10, 
        q_name = ' 4级功勋宝箱',
        q_index = 3,
        q_grade = 3
    },
    {
        q_id = 31,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, id = 8080 
            }
        },
        q_need_activepoint = 2400, 
        q_box_num = 10, 
        q_name = ' 4级功勋宝箱', 
        q_index = 4,
        q_grade = 3
    },
    {
        q_id = 32, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        }, 
        q_need_activepoint = 3200, 
        q_box_num = 10,
        q_name = '4级功勋宝箱', 
        q_index = 5, 
        q_grade = 3
    },
    {
        q_show_activepoint = 3200, 
        q_id = 33,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 6400, 
        q_box_num =10, 
        q_name = ' 4级功勋宝箱', 
        q_index = 6,
        q_grade = 3
    },
    {
        q_show_activepoint = 3200, 
        q_id = 34, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4,
                id = 8012
            }
        },
        q_need_activepoint = 9600,
        q_box_num = 10,
        q_name = ' 4级功勋宝箱',
        q_index = 7,
        q_grade = 3
    },
    {
        q_show_activepoint= 3200,
        q_id = 35,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4,
                id = 8012
            }
        },
        q_need_activopoint = 12800,
        q_box_num = 10,
        q_name = ' 4级功勋宝箱',
        q_index = 8,
        q_grade = 3
    },
    {
        q_id = 37,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002
            }
        },
        q_need_activepoint = 600,
        q_box_num = 10,
        q_name = ' 5级功勋宝箱',
        index = 1,
        q_grade = 4
    },
    {
        q_id = 38,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002 
            }
        },
        q_need_activopoint = 1200, 
        q_box_num = 10, 
        q_name = ' 5级功勋宝箱', 
        q_index = 2,
        q_grade = 4
    },
    {
        q_activitie_id = 15003, 
        q_id = 39,
        q_fix_rewards = 
        {
            {
            ncs = 1,
            num = 1,
            id = 20009, 
            losttime = 86400
            }
        },
        q_need_activepoint = 2400, 
        q_box_num =10, 
        q_name = ' 5级功勋宝箱', 
        q_index = 3,
        q_grade = 4
    },
    {
        q_id = 40, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 8080
            }
        },
        q_need_activepoint = 3600, 
        q_box_num = 10, 
        q_name = ' 5级功勋宝箱', 
        q_index = 4,
        q_grade = 4
    },
    {
        q_id = 41, 
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 4, 
                id = 8012
            } 
        },
        q_need_activepoint = 4800, 
        q_box_num = 10, 
        q_name = ' 5级功勋宝箱', 
        q_index = 5,
        q_grade = 4
    },
    {
        q_show_activepoint = 4800, 
        q_id = 42,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 9600, 
        q_box_num =10,
        q_name = ' 5级功勋宝箱', 
        q_index = 6,
        q_grade = 4
    },
    { 
        q_show_activepoint= 4800, 
        q_id = 43,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 14400, 
        q_box_num = 10,
        q_name = ' 5级功勋宝箱',
        q_index = 7, 
        q_grade = 4
    },
    {
        q_show_activepoint = 4800, 
        q_id = 44,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 19200, 
        q_box_num = 10, 
        q_name = ' 5级功勋宝箱', 
        q_index = 8, 
        q_grade = 4
    },
    {
        q_id = 46,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002
            }
        },
        q_need_activepoint = 1100,
        q_box_num =10,
        q_name = '6级功勋宝箱',
        q_index = 1,
        q_grade = 5
    },
    {
        q_id = 47,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002
            }
        },
        q_need_activepoint = 2200,
        q_box_num =10,
        q_name = ' 6级功勋宝箱',
        q_index = 2,
        q_grade = 5
    },
    {
        q_activitie_id = 15003,
        q_id = 48,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1,
                id = 20009,
                losttime = 86400
            }
            },
        q_need_activepoint = 4400,
        q_box_num = 10,
        q_name = '6级功勋宝箱',
        q_index = 3,
        q_grade = 5
    }, 
    {
        q_id = 49,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1,
                id = 8080
            }
        },
        q_need_activepoint = 6600,
        q_box_num = 10,
        q_name = '6级功勋宝箱',
        q_index = 4,
        q_grade = 5 
    }, 
    {
        q_id = 50,
        q_fix_rewards = 
        { 
            {
                ncs = 1,
                num = 4,
                id = 8012
            }
        },  
        q_need_activepoint = 8800,
        q_box_num = 10,
        q_name = ' 6级功勋宝箱',
        q_index = 5,
        q_grade = 5
    },
    {
        q_show_activepoint = 8800,
        q_id = 51, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        }, 
        q_need_activepoint = 17600, 
        q_box_num =10, 
        q_name = ' 6级功勋宝箱', 
        q_index = 6,
        q_grade = 5
    },
    {
        q_show_activepqnt = 8800, 
        q_id = 52,
        q_fix_rewards = 
        { 
            {
                ncs= 1,	
                num = 4,
                id = 8012
            }
        },
        q_need_activepoint = 26400,
        q_box_num = 1,
        q_name = ' 6级功勋宝箱',
        q_index = 7,
        q_grade = 5
    },
    {
        q_show_activepoint = 8800, 
        q_id = 53,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 35200,
        q_box_num =10, 
        q_name = ' 6级功勋宝箱',
            q_index = 8,
        q_grade = 5
    },
    {
        q_id = 55, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002
            }
        },
        q_need_activepoint = 2000,
        q_box_num = 10, 
        q_name = ' 7级功勋宝箱', 
        q_index = 1, 
        q_grade = 6
    },
    {
        q_id = 56, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002 
            }
        },
        q_need_activepoint = 4000, 
        q_box_num = 10, 
        q_name = ' 7级功勋宝箱', 
        q_index = 2,
        q_grade = 6
    },
    {
        q_activitie_id = 15003, 
        q_id = 57,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 20009, 
                losttime = 86400 
            }
        }, 
        q_need_activepoint = 8000, 
        q_box_num =10, 
        q_name = ' 7级功勋宝箱', 
        q_index = 3,
        q_grade = 6
    },
    {
        q_id = 58,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 8080
            }
        },
        q_need_activepoint = 12000, 
        q_box_num = 10, 
        q_name = ' 7级功勋宝箱', 
        q_index = 4,
        q_grade = 6
    },
    {
        q_id = 59,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 16000, 
        q_box_num = 1.0, 
        q_name = ' 7级功勋宝箱', 
        q_index = 5,
        q_grade = 6
    },
    {
        q_show_activepoint = 16000, 
        q_id = 60,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        }, 
        q_need_activepoint = 32000,
        q_box_num = 10,
        q_name = '7级功勋宝箱', 
        q_index = 6,
        q_grade = 6
    },
    {
        q_show_activepoint = 16000, 
        q_id = 61,
        q_fix_rewards = 
        {
            {
                ncs = 1, 
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 48000, 
        q_box_num =10, 
        q_name = ' 7级功勋宝箱', 
        q_index = 7,
        q_grade = 6
    },
    {
        q_show_activepoint = 16000, 
        q_id = 62,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 6400,
        q_box_num = 10,
        q_name = ' 7级功勋宝箱', 
        q_index = 8, 
        q_grade = 6
    },
    {
        q_id = 64, 
        q_fix_rewards =
        {
            {
                ncs = 1,
                num = 5, 
                id = 8002
            }
        }, 
        q_need_activepoint = 3000, 
        q_box_num = 10, 
        q_name = ' 8级功勋宝箱', 
        q_index = 1, 
        q_grade = 7
    },
    {
        q_id = 65, 
        q_fix_rewards =
        {
            {
                ncs = 1, 
                num = 5, 
                id = 8002
            }
        
        }, 
        q_need_activepoint = 6000, 
        q_box_num = 10, 
        q_name = ' 8级功勋宝箱', 
        q_index = 2, 
        q_grade = 7
    },
    {
        q_activitie_id = 15003, 
        q_id = 66, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1,
                id = 20009,
                losttime = 86400
            }
        },
        q_need_activepoint = 12000, 
        q_box_num = 10, 
        q_name = ' 8级功勋宝箱', 
        q_indux = 3,	
        q_grade = 7
    },
    {
        q_id = 67,
        q_fix_rewards = 
        {
            {
                ncs =1,
                num = 1, 
                id = 8080
            }
        },
        q_need_activepoint = 18000, 
        q_box_num = 10,
        q_name = ' 8级功勋宝箱', 
        q_index = 4,
        q_grade = 7
    },
    {
        q_id = 68, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 24000, 
        q_box_num =10,
        q_name = ' 8级功勋宝箱', 
        q_index = 5,
        q_grade = 7
    },
    {
        q_show_activepoint = 24000, 
        q_id = 69,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 48000, 
        q_box_num = 10,
        q_name = ' 8级功勋宝箱', 
        q_index = 6,
        q_grade = 7
    },
    {
        q_show_activepoint = 24000,
        q_id = 70,
        q_fix_rewards = 
        { 
            {
                ncs = 1, 
                num = 4, 
                id = 8012
            }
        },
        Q_need_activepoint = 72000, 
        q_box_num = 10,
        q_name = ' 8级功勋宝箱', 
        q_index = 7,
        q_grade = 7
    },
    {
        q_show_activepoint = 24000, 
        q_id = 71,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 96000, 
        q_box_num = 10,
        q_name = '8级功勋宝箱', 
        q_index = 8,
        q_grade = 7
    },
    {
        q_id = 73,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5, 
                id = 8002
            }
        },
        q_need_activepoint = 4000, 
        q_box_num = 10, 
        q_name = ' 9级功勋宝箱', 
        q_index = 1,
        q_grade = 8
    },
    {
        q_id = 74,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 8002
            }
        }, 
        q_need_activepoint = 8000, 
        q_box_num = 10,
        q_name = ' 9级功勋宝箱', 
        q_index = 2,
        q_grade = 8
    },
    {
        q_activitie_id = 15003, 
        q_id = 75,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 20009, 
                losttime = 86400 
            }
        },
        q_need_activepoint = 16000, 
        q_box_num = 10, 
        q_name = ' 9级功勋宝箱', 
        q_index = 3,
        q_grade = 8
    },
    {
        q_id = 76, 
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 8080
            }
        },
        q_need_activepoint = 24000, 
        q_box_num = 10, 
        q_name = ' 9级功勋宝箱', 
        q_index = 1,
        q_grade = 8
    },
    {
        q_id = 77,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 32000, 
        q_box_num = 10, 
        q_name = '9级功勋宝箱', 
        q_index = 5, 
        q_grade = 8
    },
    {
        q_show_activepoint = 32000, 
        q_id = 78,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012 
            }
        },
        q_need_activepoint = 64000, 
        q_box_num = 10,
        q_name = ' 9级功勋宝箱', 
        q_index = 6,
        q_grade = 8
    },
    {
        q_show_activepoint = 32000, 
        q_id = 79,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 96000, 
        q_box_num = 10,
        q_name = ' 9级功勋宝箱', 
        q_index = 7,
        q_grade = 8
    },
    {
        q_show_activepoint = 32000, 
        q_id = 80,
        q_fix_rewards = 
        {
            {
                ncs = 1,
                num = 4, 
                id = 8012
            }
        },
        q_need_activepoint = 128000, 
        q_box_num = 10,
        q_name = ' 9级功勋宝箱',
        q_index = 8,
        q_grade = 8
    }
}



-- return {-
-- versioninfo =
-- （
-- date = '2017-1-16 16:54:22',
-- checkvalue = * b6943d068118ee60cdbe2730f0eb44c5,,
-- version = 1484556862,
-- creater = ' JUN'
-- },
data = 
{
    
    q_finish_notify = '<font color=\"#00C8FA\">夜战楼兰古城</font>活动已结束',
    q_type = 1,
    q_show_rewards = 
    {
        8002, 20007, 8009
    },
    q_id = 10009,
    q_rewards = 
    {
        {
            ncs = 1,
            num = 3,
            id = 20007
        }
    },
    q_notify = 1,
    q_info_spare ='参与奖励：\nl、参与超过5分钟,可领取<font color=\"#53b436\">灭魔令 牌 3 个。font>\n2、击杀 10 人,可领取<font color=\"#53b436\">转生丹 5 个</font>\n3、排行前 4~10 名,可领取<font color=\"#53b436\">玄珠碎片（大）2个Ofont>\n4、排行前广3名,可领取<font color=\"#53b436\">玄珠碎片（大）4 个</fonl>',
    q_desc ='参与奖励:\nl、参与超过5分钟,可领取<font color=\"#53b436\">灭魔令牌3个 </font>\n2、击杀 10 人,可领取<font color=\"#53b436\">转生丹 5 个</font>\n3> 排行前 4~10 名, 可领取<font color=\"#53b436\">玄珠碎片（大）2个</font>\n4排行前 广3名,可领取<font color=\"#53b436\">玄珠碎片（大）4 个</font>',
    q_name ='夜战楼兰古城',
    q_notice_weight = 1,
    q_open_notify = '<font color=\"#00C8FA\">夜战楼兰古城</font>已开启,参与的勇士有机 会获得大量转生丹、稀有材料！',
    q_sort = 14,
    q_client_condition = 
    {
        {
            level = 90
        }
    },
    q_function_type = 1,
    q_info ='活动 NPC：<font color=\"#53b436\">夜战楼兰古城</font>\n 活动时间:<font color=\"#53b436\">21:20-21:40</font>\n 活动介绍:玩家在活动地图内可以<font color=\"#53b436\"> 尽情的战斗</font>,布杀其他玩家可获得积分,最终根据<font color=\"#53b436\">积分</font>的多 屠龙圣域游戏软件Vl.O 	 30 少进彳?Vont color=\"#53b43S\">排名</font>发放奖励\n\n<font color=\'@53b436\">玩家死亡不焯一 落任何物品</font>',
    q_info_spare2 ='参与奖励:\nl、参与超过5分钟,可领取<font color=\"#53b436\">火魔 令牌 3 个</font>\n2.击杀 10 人,可领取<font color=\"#53b436\">转生丹 5 个</font>\n3、排行前 4~10 名,可领取<font color=\"#53b436\">玄珠碎片（大）2个</font>\n4.排行前广3名,可领取<font color=\"#53b436\">玄珠碎片（大）4 个。font>',
    {
        q_finish_notify = '<font color=\"#00C8FA\">夜战楼兰古城</font>活动已结束',
        q_type = 1,
        q_show_rewards = 
        {
            8002, 20007, 8009
        },
    },
    q_id = 10036,
    q_rewards = 
    {
        {
            ncs = 1,
            num = 3,
            id = 20007
        }
    },
    q_notify = 1,
    q_info_spare ='参与奖励:\nl、参与超过5分钟,可领取<font color=\"#53b436\">灭魔令 牌 3 个</font>\n2、击杀 10 人,可领取<font color=\"#53b436\">转生丹 5 个</font>\n3.排行前 4~10 名,可领取<font color=\"#53b436\">玄珠碎片（大）2个</font>\n4、排行前广3名,可领取<font color=\"#53b436\"> 玄珠碎片（大）4 个。font>',
    q_desc ='参与奖励：\nl、参与超过5分钟,可领取<font color=\"#53b436\">灭魔令牌3个 </font>\n2、击杀 10 人,可领取<font color=\"#53b436\">转生丹 5 个</font>\n3> 排行前 4~10 名, 可领取<font color=\"#53b436\">玄珠碎片（大）2个</font>\n4>排行前1〜3名,可领取<font color=\"#53b436\">玄珠碎片（大）4 个</font>',
    q_name ='夜战楼兰古城',
    q_notice_weight = 1,
    q_open_notify = '<font color=\"#00C8FA\">夜战楼兰古城</font>已开启,参与的勇士有机 会获得大紙转生丹、稀有材料！',
    q_sort = 20,
    q_client_condition = 
    {
        {
            level = 90
        }
    },
    q_function_type = 1,
    qjnfo ='活动 NPC： <font color=\"53b436\">夜战楼兰占城</font>\n 活动时间：<font color=\"#53b436\">21:20-21:4（K/font>\n活动介绍:玩家在活动地图内可以<font color=\"#53b436\"> 尽情的战斗</font>,击杀其他玩家可获得积分,最终根据<font color=V«53b436\z,>积分</font>的多 少进行<font color=\"#53b436\">排名</font>发放奖励\n\n<font color=\"#53b436\">玩家死亡不掉落 任何物品</font>',
    q_info_spare2 ='参与奖励:\nl、参与超5 分钟,可领取<foqt color=\"#53b436\"宓魔 令牌 3 个</font>\n2> 击杀 10 人,可领取<font color=\"53b436\">转生丹 5 个</font>\n3.排行前 4~10 名,可领取<font color=\"#53b436\">玄珠碎片（大）2个</font>\n4.排行前广3名,可领取<font color=\"#53b436\">玄珠碎片（大）4 个</font>',
    q_finish_notify = '<font color=\"#00C8FA\">膜拜城主</font>活动已结束,敬清期待其他 活动',
    q_type = 1,	
    q_show_rewards = 
    {
        5
    },
    q_id = 10001,
    q_notify = 1,
    q_info_spare ='活动时间:每日 12： 00-13： 00',
    q_desc ='活动时间：每日 12： 00-13： 00',
    q_name ='城主膜拜',
    q_notice_weight = 1, 
    q_open_notify = ' <font color=\"#00C8FA\">膜拜城主</font>活动时间在楼兰古城膜拜城主 雕像即可获得海量经验！',
    q_sort = 1,
    q_client_condition = 
    {
        {
            level = 80
        }
    },
    q_function_type = 2,
    q_info ='活动 NPC： <font color=\"#53b436\">楼兰城主雕像</font>\n 活动时间：<font color=\"#53b436\">12:00T3:0{K/font>\n活动介绍：活动开启后,在楼兰古城安全区内膜拜城主可获 得<font color=\"#53b436\">大量经验奖励</font>,等级越高获得的经验越多',
    q_info_spare2 = 
    {
        lv = 50,
        descl = ' 50~59 级',
        desc2 ='每分钟获得160000经验'
    },
    {
        lv = 60,
        descl = ' 60~69 级',
        desc2 ='每分钟获得180000经验'
    },
    {
        lv = 70,
        descl = ' 70~79 级',
        desc2 ='每分钟获得200000经验',
        lv = 80,
        descl = '80~89 级',
        clesc2 ='每分钟获得227736经验',
        lv = 90,
        descl = '90~99 级',
        desc2 ='每分钟获得315090经验' 
    },
    { 
        lv = 100,
        descl = ' 100" 109 级',
        desc2 ='每分钟获得435951经验', 
        lv = 110,
        descl = '110~119 级',
        desc2 ='每分钟获得603172经验', 
        lv = 120,
        descl = '"129 级',
        desc2 ='每分钟获得834534经验', 
        lv = 130,
        descl = ' 130^139 级',
        desc2 ='每分钟获得1154642经验',
        lv = 140,
        descl = '149 级',
        desc2 ='每分钟获得1597536经验' 
    }, 
    {
        lv = 150,
        descl = 'T50~159 级',
        desc2 ='每分钟获得2210313经验', 
        lv = 160,
        descl = '160~169 级',
        desc2 ='每分钟获得3058137经验', 
        lv = 170,
        descl = ' 170^179 级',
        clesc2 ='每分钟获得4231168经验', 
        lv = 180,
        descl = '180~189 级',
        desc2 ='每分钟获得5854144经验', 
        lv = 190,
        descl = ' "200 级', 
        desc2 ='每分钟获得8366946经验'
    },
    {
        q_finish_notify ='在诸位勇者的全力努力卜,妖兽军团已全部被击杀！ <font color=\"#00C8FA\">怪物攻城</font>活动结束,敬请期待其他活动',
        q_type = 1,
        q_show_rewards = 
        {
            1170310405, 1170520405,1170730405, 1180810505,1181220505, 1181330505
        },
        q_notify = 5,
        q_notice ='魔君统帅 <font color=\"#53b436\">%s</font>带领大批怪物出现在@<font color\"#53b436\">{%d,%d}</font>,击杀可获得大量金币和装备奖励。伊, 了一',
        q_id = 10003,
        q_name ='怪物攻城',
        q_notice_weight = 1,
        q_open_notify = '<font color=\"#00C8FA\">怪物攻城。font>活动开启,妖曾军团从<font color=\"#00C8FA\">134, 12</font>和<font color=\"#0{}C8FA\">130,150</font>开始攻袭楼兰古城,请 众勇士拿起你们的武器,誓死守卫我们的家园！',
        q_sort = 2,
        q_notice_time = '5 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55 14 * * ?',
        q_client_condition =
        {
            {
                level = 80
            }
        },
        q_function_type = 3,
        q_info = '活动 NPC： <font color=\"#53b436\">楼兰古城传送员</font>\n 活动时间:<font color=\"#53b436\">14:00-15:0{K/font>\n 活动介绍:大批魔军分别从 <font color=\"#53b436V>{110, 75} {131, 150}</font> 开始突袭 <font color=\"#53b436\"> 楼兰古城 {110, 75}</font>,古城的安危就在各路英雄的手中,战胜魔王将有机会获得<font color=\"#53b436\"> 高级装备</font>'
    },
    {
        q_finish_notify = '<font color=\"#00C8FA\">寻龙诀</font>活动已结束,敬请期待其他活 动',
        q_type = 1,
        q_show_rewards = 
        {
            5, 8007,8009,8011,8013
        },
        q_notify = 5,
        q_id = 10004,
        q_info_spare = '<font color=\"#53b436\">活动时间:每日 15： 00-15： 20\n 参与等级：70 级以上</font>',
        q_desc = '<font color=\"#53b436\">活动时间：每日 15： 00-15： 20\n 参与等级：70 级以上 </font>',		
        q_name = '寻龙诀',
        q_notice_weight = 1,
        q_open_notify = '<font color=\"#00C8FA\"> 寻龙诀 </font> 活动开启了,请前往楼兰古城参•加,获得海斌经验、珍稀材料奖励！',
        q_sort = 3,
        q_client_condition = 
        {
            {
                level =80
            }
        },
        q_function_type = 4,
        q_info = '活动 NPC： <font color=\"#53b436\">楼兰古城传送员</font>\n 活动时间:<font color=\"#53b436\">15:00-15:20</font>\n活动介绍:活动开启后,只要站在寻龙诀祭坛周围<font color=\"#53b436\">12</font>格范围内,即可获得<font color=\"#53b436\">大屋的奖励<7fontX/br> 其中神龙祭坛产出<font color=\"#53b436\">更丰厚奖励</font>!'
    },
    {
        q_finish_notify = ' <font color=\"#{}0C8FA\">元宝嘉年华</font>活动已结束,敬请期待其他 活动',
        q_type = 1,
        q_show_rewards = 
        {
            2, 2, 2, 2, 2, 2
        },
        q_notify = 5,
        q_id = 10005,
        q_name ='元宝嘉年华',
        q_notice_weight = 1,
        q_open_notify = '<font color=\"#00C8FA\">元宝嘉年华</font>开启了！ BOSS【元宝龟】携 带大量元宝出现在楼兰古城{63,110}附近,击杀可获得大量绑定元宝奖励',
        q_sort = 4,
        q_client_condition =
        {
            {
                level = 80
            }
        },
        q_function_type = 5,
        q_info ='活动 NPC： <font color=\"#53b436\">楼兰古城</font>\n 活动时间：<font color=\"#53b436\">16:0{K/font>\n 活动介绍：<font color=\"53b436\">B0SS［元宝龟］</font>携带大 量宝藏,岀现在<font color=\"#53b436\">楼兰古城{164, 124}</font> ,击杀他可掉落<font color=\"#53b436\">大量元宝</font>奖励,掉落为<font color=\"#53b436\"> 门由拾取</font>',
    },
    {
        q_finish_notify = '<font color=\"#00C8FA\">元宝嘉年华</font>活动已结束',
        q_type = 1,
        q_show_rewards = 
        {
            2
        },
        q_notify = 5,
        q_id = 10010,
        q_name ='元宝嘉年华',
        q_notice_weight = 1,
        q_opennotify = '<font color=\"#00C8FA\">元宝嘉年华</font>开启了！ BOSS【元宝龟】携 带大量元宝出现在楼兰.占城{60, 106},击杀他可获得大量元宝、绑定元宝奖励', 
        q_sort = 8,
        q_client_condition = 
        {
            {
                level = 70
            } 
        },
        q_function_type = 5,
        Q_info ='活动 NPC : <font color=\"#53b436\"> 楼兰古城 </ font>\n 活动时间：<font color=\"#53b436\">20:00</font>\n 活动介绍:<font color=\"#53b436\">B0SS［元宝龟］</font>携带大 蛍宝藏,出现在<font color=\"#53b436\">楼兰古城</font>,击杀可掉落<font color=\"#53b436\">大 量的元宝、绑定元宝</font>奖励,掉落为<font color=\"#53b436\">ri由拾取</font>',
    },
    {
        q_type = 1,	
        q_function_type = 6,
        q_id = 10006,
        q_name ='全服双倍经验',
        Q_sort = 5,
        q_client_condition = 
        {
            {
                level = 1
            }
        },
        q_show_rewards = 
        {
            5
        },
        q_info ='活动时间:<font color=\"#53b436\",>13:00-14:00</font>\n 参与等级：<font color=\"#53b436\">l级</font>\n活动介绍：活动期间开启全服双倍经验,击杀任何怪物均可获得双倍 经验奖励'
    },
    {
        q_type = 1,
        q_function_type = 6,
        q_id = 10007,
        q_name ='全服双倍经验',
        q_sort = 6,
        q_client_condition = 
        {
            {
                level = 1
            }
        },
        q_show_rewards = 
        {
            5
        },
        q_info ='活动时间:<font color=\"#53b436\">21:00-22:00</font>\n 参与等级：<font color=\"#53b436\">l级</font>\n活动介绍：活动期间开启全服双倍经验,由杀任何怪物均可获得双倍 经验奖風',
    },
    {
        q_type = 1,
        q_function_type = 7,
        q_id = 10008,
        q_name ='零点事件',
        q_notice_weight = 1,
        q_sort = 7,
        q_client_condition = 
        {
            {
                level = 0
            }
        },
        q_info ='零点事件'
    },
    {
        q_type = 1,
        q_show_rewards = 
        {
            3,2,8506
        },
        q_id = 10026,
        q_info_spare ='参与奖励:\n1、参与超过5分钟,可领取<font color=\"#53b436\">9个魂 珠碎片</font>\n2.击杀10人,可领取<font color=\"#53b436\">9个魂珠碎片</font>\n3、排行前10 名,可领取 <font col（）r=\"#53b436\">9 个魂珠碎片</font>',
        q_desc ='参与奖励:\nk参与超过5分钟,可领取<font color=\"#53b436\">9个魂珠碎片. </font>\n2、击杀 10 人,可领取<font color=\"#53b436\">9 个魂珠碎片</font>\n3.排行前 10 名,可 领取<font color=\"#53b436\">9 个魂珠碎片</font>',
        q_name ='攻城战',
        q_notice_weight = 1,
        q_sort = 12,
        q_function_type = 8,
        q_info ='活动时间:<font color=\"#53b436\">20:00-21:00</font>\n 活动介绍：<font color=\"#53b436\">开服第四天、合服第五天</font>自动开启</br>其它时间需<font color=\"#53b436\">行会会长（副会长）</font>向攻城管理员申请。br>活动期间玩家可以<font color=\"#53b436\">尽情的战斗</font>,在活动中占领皇宮,成为霸主,赢得<font color=\"#53b436\"> 专属武器和专属称号。font>',
        q_info_spare2 ='参与奖励:\nl> 参与超过 5 分钟,可领取<font color=\"#53b436\">9 个魂 珠碎片</font>\n2>击杀10人,可领取<font color=\"#53b436\">9个魂珠碎片</font>\n3^排行前10 名,可领取<font color=\"#53b436\">9 个魂珠碎片</font>'
    },
    {
        q_finish_notify = '<font color=\"#00C8FA\">帝王陵入口</font>已关闭请诸位勇士等待卜 一次入口的开启',
        q_tuijian = 1,
        q_type = 1,
        q_show_rewards = 
        {
            1180010505, 1180020505, 1180030505, 25028
        },
        q_notify = 5,
        q_id = 10028,
        q_name ='帝陵探索',
        q_notice_weight = 1,
        q_open_notify ='请前往<font color=\"#00C8FA\">帝土陵</font>参与摸金校尉任务巾杀帝 王可获得神级装备！速前往楼 l^font color=\"#00C8FA\">128, 138</font>进心。',
        q_sort = 23,
        q_client_condition = 
        { 
            {
                level = 90,
            }
        },
        q_function_type = 9,
        q_info ='活动 NPC： <font color=\"#53b436\">楼兰摸金校尉</font>\n 活动时间：<font color=\"#53b436\">0-24</font>点每<font color=\"#53b436\">2</font>小时开启一次\n 活动介绍：帝 王陵共<font color=\"#53b436\">三层</font>陵窮内部怪物掉落进帝王冢凭证<font color=\"#53b436\">帝王陵印记</font> ! \n<font color=\"#53b436\">楼兰古帝</font> T帝王冢内沉 眠\n</font>击杀可获得<font color=\"#53b436\">神级装备、终极技能</font>',
        q_info_spare2 = '0 以上'
    },
    {
        q_finish_notify = '<font color=\"#00C8FA\">車装使者</font>活动已结束,请诸位勇士等 待下一次活动的开启',
        q_tuijian = 1,
        q_type = 1,
        q_show_rewards = 
        {
            1180010505,1180020505,1180030505, 8011, 8007, 8013
        },
        q_notify = 5,
        q_id = 10030,
        q_name ='重装使者',
        q_notice_weight = 1,
        q_open_notify = ' <font color=\"#00C8FA\">重装使者</font>已开启,参与可获得极品材料 和装备！请速速前往楼兰古城参与活动。',
        q_sort = 9,
        q_client_condition = 
        {
            {
                level = 85
            }
        },
        q_function_type = 10,
        q_info ='活动 NPC： <font color=\"*53b436\">楼兰重装使者</font>\n 活动时间：<font color=\"#53b436\">19:00-19:30</font>\n 活动介绍：活动时间内,场景刷新共 6 波<font color=\"#53b436\">“重装守卫（精英）及金龙殿主（BOSS）”</font>,掉落各种<font color=\"#53b436\"> 高级材料、转生装备</font>等；掉落的物品需持有<font color=\"#53b436\">l分钟</font>后才可真正 获得,临时持有时间内掉线、离开场景、死亡将掉落所得。',
        q_info_spare2 = ' 0 以上'
    },
    {
        q_finish_notify = '<font color=\"#00C8FA\">車装使者</font>活动已结束,请诸位勇士等 待卜一次活动的开启',
        q_tuijian = 1,
        q_type = 1,
        q_show_rewards = 
        {
            1180010505,1180020505,1180030505,8011, 8007, 8013
        }, 
        q_id = 10031,
        q_name ='重装使者',
        q_notice_weight = 1,
        q_open_notify = ' <font color=\"#00C8FA\">重装使者。font>已开牌,参与可获得极品材匚 料和装备！淸速速前往楼兰古城参与活动。',
        CL_sort = 10,
        q_client_condition = 
        {
            level = 85
        },
        q_function_type = 10,
        q_info ='活动 NPC： <font color=\"#53b436\">楼兰重装使者</font>\n 活动时间:<font color=\"#53b436\">19:00-19:30</font>\n 活动介绍:活动时间内,场景刷新共 6 波<font color=\"53b436\">“重装守卫（精英）及金龙殿主（B0SS）M</font>,掉落各种<font color=\"#53b436\"> 高级材料、转生装备</font>等；掉落的物品需持仃<font color=\"#53b436\"> 1分钟</font>后才可真正 获得,临时持有时间内掉线、离开场景、死亡将掉落所得。',
        q_info_spare2 = ' 0 以上'
    },
    {
        q_finish_notify = ' <font color=\"#00C8FA\">重装使者</font>活动已结束,请诸位勇士等 待下一次活动的开启',
        q_tuijian = 1,
        q_type = 1,
        q_show_rewards = 
        {
            1180010505, 1180020505, 1180030505, 8011,8007, 8013
        }, 
        q_id = 10032,
        q_name ='重装使者',
        q_notice_weight = 1,
        q_open_notify = ' <font coloi”=\"#00C8FA\">重装使者</font>已开启,参与可获得极品材料 和装备！请速速前往楼兰古城参与活动。',
        q_sort = 11,
        q_client_condition = 
        {
            {
                level = 85
            }
        },
        q_function_type = 10,
        q_info ='活动 NPC： <font color=\"#53b436\">楼兰重装使者</font>\n 活动时间：<font color=\"#53b436\z,>19:00*19:30</font>\n 活动介绍：活动时间内,场景刷新共 6 波 <font color=\"#53b436\">“重装守卫（精英）及金龙殿主（B0SS）”</font>,掉落各种<font color=\"#53b436\"> 高级材料、转生装备</font>等；掉落的物品需持冇Cfontcolor=\"#53b436\">l分钟</font>后才可真止 获得,临时持有时间内掉线、离开场景、死亡将掉落所得。',
        q_info_spare2 = '0 以上'
    },
    {
        q_finish_notify = ' <font color=\"#00C8FA\">重装使者</font>活动已结朿,谙诸位勇士等 待下--次活动的开启',
        q_tuijian = 1,
        q_type = 1,
        q_show_rewards = 
        {
            1220010509, 1220020509, 1220030509, 8011,8007,8013 
        },
        q_notify = 5,
        q_id = 10033,
        q_name ='重装使者',
        q_notice_weight = 1,
        q_open_notify = ' <font color=\"#00C8FA\">重装使者</font>已开启,参与可获得极品材料 和装备！请速速前往楼兰占城参与活动。',
        q_sort = 17,
        q_client_condition = 
        {
            {
                level = 85
            }
        },
        q_function_type =10,
        q_info ='活动 NEC： <font color=\"#53b436\">楼兰重装使者。fonl>\n 活动时间：<font color=\"#53b436\">19:00-19:30</f ont>\n 活动介绍：活动时间内,场景刷新共 6 波<font color=\"#53b436\">“重装守卫（精英）及金龙殿主（BOSS）”</font>,掉落各种<font color=\"#53b436\"> 高级材料、转生装备。font>等；掉落的物品需持有Cfontcolor=\"#53b436\">l分钟</font>后才可真正 获得,临时持有时间内掉线、离开场景、死亡将掉落所得。',
        q_info_spare2 = ' 0 以上'
    },
    {
        q_finish_notify = '<font color=\"#00C8FA\">重装使者</font>活动已结束,请诸位勇士等 待下一次活动的开启',
        q_tuijian = 1,
        q_type = 1,
        q_show_rewards = 
        {
            1220010509,1220020509,1220030509, 8011, 8007, 8013
        },
        q_id = 10034,
        q_name ='重装使者',
        q_notice_weight = 1,
        q_open_notify = ' <font color=\"#00C8FA\">重装使者</font>已开启,参与可获得极品材料 和装备！请速速前往楼兰古城参与活动。',
        q_sort = 18,
        q_client_condition = 
        {
            {
                level = 85
            }
        },
        q_function_type =10,
        q_info ='活动 NPC： <font color=\"#53b436\">楼兰重装使者</font>\n 活动时间：<font color=\"#53b436\">19:00-19:30</font>\n 活动介绍：活动时间内,场景刷新共 6 波<font color=\"#53b436\">“車装守卩（精英）及金龙殿主（BOSS）”</font>,掉落各种<font color=\"#53b436\"> 高级材料、转生装备</font>等；掉落的物品需持有<font color=\"#53b436\">I分钟</font>后才可真止 获得,临时■持冇时间内掉线、离开场景、死亡将掉落所得。',
        q_info_sparg2 = '0 以上',	
    },
    {
        q_finish_notify = '待下一次活动的开启',
        q_tuijian = 1,
        q_type = 1,
        q_show_rewards = 
        {
            1220010509, 122.0020509, 1220030509,8011,8007, 013
        },
        q_id = 10035,
        q_name ='重装使者',
        q_notice_weight = 1,
        q_open_notify = '<font color=\"#00C8FA\">車装使者</font>已开启,参与可获得极品材料 和装备！请速速前往楼兰古城参与活动。',
        q_sort = 19,
        q_client_condition = 
        {
            {
                level = 85
            }
        },
        q_function_type = 10,
        q_info ='活动 NPC： <font color=\"#53b436\">楼兰重装使者。font>\n 活动时间：<font color=\"#53b436\">19:00-19:30</font>\n 活动介绍：活动时间内,场景刷新共 6 波 <font color=\"#53b436\">“ 車装守卫{精英}及金龙殿主{BOSS},,</font>,掉落各种<font color=\"#53b436\"> 高级材料、转生装备</font>等；掉落的物品需持有<font color=\"#53b436\">l分钟</font>后才可真正 获得,临时持有时间内掉线、离开场景、死亡将掉落所得。',
        q_info_spare2 = ' 0 以上'
    },
    {
        q_type = 1,
        q_function_type = 11,
        q_id = 10027,
        q_name ='刷新攻城守卫',
        q_sort = 13,
        q_client_condition =         
        {
            {
                level = 85
            }
        },
        q_info_spare2 = ' 3 以上'
    },
    {
        q_type = 1,
        q_function_type = 12,
        q_id = 10029,
        q_show_rewards = 
        {
            {
                num = 1000,
                id = 4
            }
        },
        q_name ='门派挑战每日结算',
        q_sort = 24,
        q_info_spare2 = ' 0 以上'	
    },
    { 
        q_type = 1,  
        q_show_rewards = 
        {
            22, 8030,8100 
        },
        q_id = 10050, 
        q_rewards = 
        {
            num = 200, id = 22,
            num = 2, id = 8030,
            num = 2, id = 8100
        },
    },
    {
        q_notify = 1,
        q_info_spare ='参与奖励：\nl、参与时长超过 5 分钟,可领取<font color=\"#53b436\">200 功勋、200w金币及技能领悟丹2个。</font>\n2、击杀10人,可领取<font color=\"#53b436\">技能领 悟丹 5 个</font>o \n3、排行前 20~il 名,可领取<font color=\"#53b436\">400 功勋、400w 金币及技 能领悟丹4个</font>„ \n4、排行前；4~10名,可领取<font color=\"#53b436\">600功勋、600w金币及 技能领悟丹6个。font>o \n5、排行,前广3名,可领取<font color=\"#53b436\">800功勋、800w金币 及技能领悟丹8个</font>',
        q_desc ='参与奖励：\nl、参与时长超过5分钟,可领取<font color=\"#53b436与>200功勋、 200w金币及技能领悟丹2个。</font>\n2、击杀10人,可领取<font color=\"#53b436\">技能领悟丹5 个</font>o \n3^排行前20~11名,可领取<font color=\"#53b436\">400功勋、400w金币及技能领悟 丹4个</font>0 \n4、排行前4~10名,可领取<font color=\"#53b436\">600功勋、600w金币及技能领 悟丹6个</font>。\n5、排行前1〜3名,可领取<font color=\"#53b436\">800功勋、800w金币及技能 领悟丹8个</font>o ',
        q_name ='皇城大乱斗',
        q_notice_weight = 1,
        q_open_notify = ' <font color=\"#00C8FA\">皇城大乱斗</font>已开启,参与的勇士有机会 获得功勋、金币及技能领悟丹！',
        q_sort = 15,
        q_client_condition =
        {
            {
                level = 85
            }
        },
        q_function_type = 13,
        q_info ='活动 NPC： <font color=\"#53b436\">皇城大乱斗</font>\n 活动时间:<font color=\"#53b436\"> 13:00-13:20</font>\n活动介绍：公城之内将屏蔽玩家信息并统一■形象,<font color=\"#53b436\">尽情战斗吧</font> !击杀其他玩家可获得积分,最终根据<font color=\"#53b436\"> .积分 </font> 的多少给予 <font coloi*\"#53b436\"> 排名 «font> 发放奖励。.\n\n<font 二。1。厂\"#531）436\">玩家死亡不掉落任何物品</font>',
        q_info_spare2 = '参与奖励：\nl、参与时长超过 5 分钟,可领取<font color=\"#53b436\">200 功勋、200w金币及技能领悟丹2个。</font>\n2>巾杀10人,可领取<font color=\"#53b436\">技能领 桔丹 5 个</「ont>。\nk 排行前 20~11 名,可领取<font color=\"#5^b436\">400 功勋、4{}{}.金币及— 技能领悟丹4个</font>o \n4、排行前4~1。名,可领取<font color=\"#53b436\">600功勋、600w金币 及技能领悟丹6个</font>。\n5、排行前1~3名,可领取<font color=\"#53b436\">800功勋、800w金 币及技能领悟丹8个</font>0 ',
        q_finish_notify = '<font color=\"#00C8FAV">皇城大乱斗</font>活动已结束 q_type = 1',
        q_show_rewards = 
        {
            22,8030,8100
        },
        q_id = 10037,
        q_rewards = 
        {
            {
                num = 200,
                id = 22, 
                num = 2,
                id = 8030
            },
            {
                num = 2,	
                id = 8100
            }
        },
    },
    {
        q_notify = 1,
        q_info_spare ='参与奖励:\nl> 参与时氏超过 5 分钟,可领取<font color=\"#53b436\">200 功勋、200w金币及技能领悟丹2个。</font>\n2>击杀10人,可领取<font color=\"#53b436\">技能领 悟丹 5 个</font>o \n3^ 排行前 20" 11 名,可领取<font color=\"#53b436\">400 功勋、400w 金币及技 能领悟丹4个</font>0 \n4、排行前4~10名,可领取<font color=\"#53b436\">600功勋、600w金币及 技能领悟丹6个。font>。\n5、排行前1~3名,可领取<font color=\"#53b436\">800功勋、800w金币 及技能领悟丹8个</font>',
        q_desc ='参与奖励:\nl、参与时长超过5分钟,可领取<font color="53b436">200功勋、 200w金币及技能领悟丹2个。</font>\n2、击杀10人,可领取<font color=\"#53b436\">技能领悟丹5 个</font>« \n3、排行前20~11名,可领取<font color=\"#53b436\">400功勋、400w金币及技能领悟 丹4个</font>o \n4、排行前4~10名,可领取<font color=\"#53b436\">600功勋、600w金币及技能领 悟丹6个</font>0 \n5、排行前广3名,可领取<font color=\"#53b436\">800功勋、800w金币及技能 领悟丹8个</font>。',
        q_name ='皇城大乱斗',
        q_notice_weight = 1,
        q_open_notify = '<font color=\"#00C8FA\">皇城大乱斗</font>已开启,参与的勇士有机会 获得功勋、金币及技能领悟丹！',
        q_sort = 21,
        q_c1ient_condition = 
        {
            {
                level = 8
            }
        },
        q_function_type = 13,
        q_info ='活动 NPC：<font color=\"#53b436\">皇城大乱斗</f（）nl>\ru活动时间： color=#53b436>13:00-13:20</font>\n活动介绍：皇城之内将屏蔽玩家信息并统一形象,<font co］（）r="#53b436">尽情战斗吧</font>！击杀其他玩家可获得积分,最终根据<fonl color=\"#53b436\"> 积分 </font> 的多少给予 <font color=\"#53b436\"> 排名 </font> 发放奖励。\n\n<font color=\"#53b436\">玩家死亡不掉落任何物品"font>',
        q_info_spare2 ='参与奖励：\nl、参与时长超过 5 分钟,可领取<font color=\"#53b436\">200 功勋、200w金币及技能领悟丹2个。</font>\n2、击杀10人,可领取<font color=\"#53b436\">技能领 悟丹 5 个</font>0 \n3、排行前 20~11 名,可领取<font color=\"#53b436\">4（）0 功勋、400w 金币及技 能领悟丹4个</font>0 \n4、排行前4~10名,可领取<font color=\"#53b436\">600功勋、600w金币及 技能领悟丹6个</font>。\n5、排行前广3名,可领取<font color=\"#53b436\">800功勋、800w金币 及技能领悟丹8个</font>。',
    },
    {
        q_finish_notify = ' <font color=\"#00C8FA\">天下第一</font>活动已结束',
        q_type = 1,
        q_show_rewards = 
        {
            1, 8030
        },
        q_notify = 1,
        q_rewards = 
        {
            {
                num = 2000, 
                id = 1
            },
            {
                num = 10,
                id = 8030
            }
        }
    },
    {
        q_id = 10051,
        q_name ='天下第一',
        q_notice_weight = 1,
        q_open_notify = '<font co].or=\"#00C8FA\">天下第一</font>已开启,最终获胜者可获得"天 卜第一”称号及元宝奖励！',
        q_sort = 16,
        q_c1ient_condition = 
        {
            {
                level = 80
            }
        },
        q_function_type = 14,
        q_info ='活动 NPC： <font color=\"#53b436\">天卜第 _</font>\n 活动时间：<font co 1 or=\"#53b436\">l 1:30-12:00</font>\n 活动介绍：活动前 10 分钟为报名时段,<font color=\"#53b436\">该时段内无法PK</font>0比赛阶段可自由PK,最终获胜的玩家将获得<font color=\"#53b436\">^c卜第一称号及大量元宝</font>,其他玩家可获得<font color=\"#53b436\">大量 金币奖励</font>0 \n\n<font color=\"#53b436\">玩家死亡不掉落任何物nn</font>',
        q_finish_notify = '<font color=\"#00C8FA\">天卜第一</font>活动已结朿 q_type = 1', 
        q_show_rewards = 
        {
            1, 8030
        },
        q_notify = 1,
        q_rewards = 
        {
            {
                num = 2000,
                id = 1
            },
            {
                num = 10,
                id = 8030
            }
        },
    },
    {
        q_id = 10038,
        q_name ='天下第一',
        q_notice_weight = 1,
        q_open_notify = ' <font color=\"#00C8FA\">天下第一</font>已开启,最终获胜者可获得"大 下第一”称号及元宝奖励！',
        q_sort = 22,
        q_c1ient_condition = 
        {
            {
                level = 80
            }
        },
        q_function_type = 14,
        q_info ='活动 NPC: <font color=\"#53b436\"> 天下第—</font>\n 活动时间：<font color=V«53b436V>ll:30-12:00</font>\n 活动介绍：活动前 10 分钟为报名时段,<font color=\"#53b436\">该时段内无法PK</font>0比赛阶段可自由PK,最终获胜的玩家将获得<font color=\"#53b436\">天下第一称号及大量元宝</font>,其他玩家可获得<font color=\"#53b436\">大埴 金币奖励</font>。\n\n<font color=\"#53b436\">玩家死亡不掉落任何物品</font>',
    },
    {
        q_type = 2,
        q_enter_button = 119, 
        q_show_rewards = 
        {
            {
                num = 100,
                id = 2
            },
            {
                num = 1,
                id = 8030
            },
            {
                num = 1,
                id = 21001
            },
            {
                num = 1, 
                id = 8104 		
            }
        },
        q_id = 20001,
        q_rewards = 
        {
            {
                num = 100,
                id = 2
            },
            {
                num = 1,
                id = 8030
            },
            {
                num = 1,
                id = 21001
            },
            {
                num = 1,
                id = 8104
            }
        },
        q_name ='签到 1 次',
        q_notice_weight =1,
        q_info ='每日签到'
    },
    {
        q_type = 2,
        q_enter_button = 119,
        q_show_rewards = 
        {
            {
                num = 200,
                id = 2
            },
            {
                num = 1,
                id = 8030
            },
            {
                num = 4,
                id = 20001
            },
            {
                num = 1,
                id = 21001
            }
        },
        q_id = 20002,
        q_rewards = 
        { 
            {
                num = 200,
                id = -2,
            },
            {
                num =1, 
                id = 8030
            },
            {
                num = 4, 
                id = 20001 
            }, 
            {
                num = 1, 
                id = 21001 
            }
        },
        q_name ='签到 2 次', 
        q_notice_weight = 1, 
        q_info ='每日签到'
    },
    {
        q_type = 2, 
        q_enter_button = 119, 
        q_show_rewards = 
        {
            {
                num = 300, 
                id = -2
            },
            {
                num = 2, 
                id = 8030
            },
            {
                num = 5, 
                id = 8505
            },
            {
                num = 1, 
                id = 20005
            }
        },
        q_id = 20003, 
        q_rewards = 
        {
            {
                num = 300,
                id = -2
            },    
            {
                num = 5,
                id = 8505
            },
            {
                num = 1, 
                id = 20005
            }
        },
        q_name ='签到 4 次',
        q_notice_weight = 1,
        q_info ='每日签到'
    },
    {
        q_type = 2,
        q_enter_button = 119,
        q_show_rewards = 
        {
            {
                num = 400,
                id = -2
            },
            {
                num = 3,
                id = 8030
            },
            {
                num = 2, 
                id = 8511
            },
            {
                num = 1, 
                id = 8015
            }
        },
        q_id = 20004,
        q_rewards = 
        {
            {
                num = 400, 
                id = -2
            },
            {
                num = 3, 
                id = 8030
            },
            {
                num = 2, 
                id = 8511 
            },
            {
                num = 1,			
                id = 8015
            }
        },
        q_name ='签到 7 次',
        q_notice_weight = 1,
        q_info ='每日签到'
    },
    {
        q_type = 2,
        q_enter_button = 119,
        q_show_rewards = 
        {
            {
                num = 500,
                id = -2
            },
            {
                num = 4, 
                id = 8030
            },
            {
                num = 5, 
                id = 20005
            },
            {
                num = 5, 
                id = 8505
            }
        },
        q_type = 2, 
        q_enter_button = 119, 
        q_show_rewards = 
        {
            {
                num = 300, 
                id = -2
            },
            {
                num = 2, 
                id = 8030
            },
            {
                num = 5, 
                id = 8505
            },
        },
    },
    {
        q_type = 1, 
        q_id = 20005,
        q_id = 20003,
        q_rewards = 
        {
            {
                num = 300,
                id = -2	
            },
            {
                num = 2,
                id = 8030
            },
            {
                num = 5,
                id = 8505
            },
            {
                num = 1,
                id = 20005
            }
        },
        q_name ='签到 4 次',
        q_notice_weight = 1,
        q_info ='每日签到'
    },
    {
        q_type = 2,
        q_enter_button = 119,
        q_show_rewards = 
        {
            {
                num = 400,
                id = -2
            },
            {
                num = 3,
                id = 8030
            },
            {
                num = 2,
                id = 8511
            },
            {
                num = 1,
                id = 8015
            }
        },
        q_id = 20004,
        q_rewards = 
        {
            {
                num = 400,
                id = -2
            },
            {
                num = 3, 
                id = 8030
            },
            {
                num = 2, 
                id = 8511
            },
            { 
                num = 1, 
                id = 8015
            }
        },
        q_name ='签到 7 次', 
        q_notice_weight = 1, 
        q_info ='每日签到'
    },
    { 
        q_type = 2, 
        q_enter_button = 119, 
        q_show_rewards = 
        {
            {
                num = 500, 
                id = -2
            },
            { 
                num = 4, 
                id = 8030
            },
            { 
                num = 5, 
                id = 20005
            }, 
            {
                num = 5, 
                id = 8505
            } 
        }, 
        q_id = 20005, 
        q_rewards = 
        {
            {
                num = 500, 
                id = - 2
            },
            { 
                num = 4, 
                id = 8030
            },
            {
                num = 5, 
                id = 20005		
            },
            {
                num = 5,
                id = 8505
            }
        },
        q_name ='签到 10 次',
        q_notice_weight = 1,
        q_info ='每日签到'
    },
    {
        q_type = 2,
        q_enter_button = 119,
        q_show_rewards = 
        {
            {
                num = 800,
                id = -2
            },
            {
                num = 5,
                id = 8030
            },
            {
                num = 5,
                id = 8511
            },
            {
                num = 1,
                id = 8016
            }
        },
        q_id = 20006,
        q_rewards = 
        {
            {
                num = 800,
                id = -2
            },
            {
                num = 5,
                id = 8030
            },
            {
                num = 5,
                id = 8511
            }, 
            { 
                num = 1,
                id = 8016 
            }
        },
        q_name ='签到 14 次', 
        q_notice_weight = 1, 
        q_info ='每日签到'
    },
    {
        q_type = 2, 
        q_enter_button = 119, 
        q_show_rewards = 
        {
            {
                num = 1000, 
                id = -2
            },
            {
                num = 6, 
                id = 8030
            },
            {
                num = 30, 
                id = 20001
            },
            {
                num = 20, 
                id = 8505
            }
        },
        q_id = 20007,
        q_rewards = 
        {
            {
                num = 1000, 
                id = -2
            },
            {
                num = 6, 
                id = 8030
            },
            {
                num = 30, 
                id = 20001 
            }, 
            {
                num = 20, 
                id = 8505
            }
        },
        q_name ='签到 21 次', 
        q_notie_weight = 1, 
        q_info ='每日签到',
    },
    {
        q_type=2,
        q_enter_button = 119,
        q_show_rewards = 
        {
            {
                num = 5000,
                id = -2
            },
            {
                num = 8,
                id = 8030  
            },
            {
                num = 15,   
                id = 8511
            },
            {
                num = 1,
                id = 8017
            }
        },
        q_id = 20008,
        q_rewards = 
        {
            { 
                num = 5000,	
                id = -2
            },
            {
                num = 8,
                id = 8030
            },
            {
                num = 15,
                id = 8511
            },
            {
                num = 1, 
                id = 8017
            }
        },
        q_name ='签到 28 次', 
        q_notice_weight = 1, 
        q_info ='每日签到'
    },
    {
        q_type = 3, 
        q_enter_button = 1024, 
        q_show_rewards = 
        {
            {
                ncs = 1,
                num = 1,
                id = 8106,
            },
            {
                ncs = 1,
                num = 100,
                id = -2
            },
            {
                ncs = 1, 
                num = 1,
                id = 8031
            }
        },
    },
    {
        q_id = 3, 
        q_rewards = 
        {
            {
                ncs = 1, 
                num = 1,
                id = 8106
            },
            { 
                ncs = 1, 
                num = 100, 
                id = -2
            },
            {
                ncs = 1, 
                num = 1, 
                id = 8031
            }
        },
        q_name ='每日在线5分钟', 
        q_sort = 1,
        q_info = 1
    },
    {
        q_type = 3, 
        q_entcr_button = 1024, 
        q_show_rewards = 
        {
            {
                ncs = 1,
                num = 1, 
                id = 8106
            },
            {
                ncs = 1,
                num = 6, 
                id = 8505
            },
            { 
                ncs = 1,
                num = 2,
                id = 8031
            }
        },
        q_id = 31013,
        q_rewards = 
        {
            {
                ncs = 1,
                num = 1,
                id = 8106
            },
            {
                ncs = 1,
                num = 6,
                id = 8505
            },
            {
                ncs = 1,
                num = 2,
                id = 8031
            }
        },
        q_name ='每日在线5分钟',
        q_sort = 1,
        q_info = 2
    },
    {
        q_type = 3,
        q_cnter_button = 1024,
        q_show__rewards = 
        {
            {
                ncs = 1,
                num = 2,
                id = 8106
            },
            {
                ncs = 1,
                num = 9,
                id = 8505
            },
            {
                ncs = 1,
                num = 2,
                id = 8031
            }
        },
        q_id = 32013,
        q_rewards = 
        {
            {
                ncs = 1,			
                num = 2,
                id = 8106
            },
            {
                ncs = 1,
                num = 9,
                id = 8505
            },
            {
                ncs = 1,
                num = 2,
                id = 8031
            },
        },
        q_name ='每日在线‘5分钟',
        q_sort =1,
        q_info = 3
    },
    {
        q_type = 3,
        q_enter_button = 1024,
        q_show_rewards = 
        {
            {
                ncs = 1,
                num = 2,
                id = 8106
            },
            {
                ncs = 1,
                num = 12,
                id = 8505
            },
            {
                ncs = 1,
                num = 3,
                id = 8031
            }
        },
        q_id = 33013,
        q_rewards = 
        {
            {
                ncs = 1,
                num = 2,
                id = 81.06
            },
            {  
                ncs = 1,
                num = 12,
                id = 8505 
            },
            {
                ncs = 1,
                num = 3,
                id = 8031
            }
        },
        q_name ='每日在线5分钟',
        q_sort = 1,
        q_info = 4
    },
    {
        q_type = 3,
        q_enter_button = 1024,
        q_show_rewards = 
        {
            {
                ncs = 1,
                num = 3,
                id = 8106
            },
            {
                ncs = 1,
                num =15,
                id = 8505
            },
            {
                ncs = 1,
                num = 3,
                id = 8031
            }
        },
        q_id = 34013,
        q_rewards = 
        {
            {
                ncs = 1,
                num = 3,
                id = 8106
            },
            {
                ncs = 1,
                num = 15,
                id = 8505
            },
            {
                ncs = 1,
                num = 3,
                id = 8031
            }
        },
        q_sort = 1,
        q_info = 5
    },
    {
        q_type = 3,
        q_enter_button = 1024,
        q_show__rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 15
            },
            { 
                ncs = 1,
                num = 100,
                id = 2
            },
            {
                ncs = 1,
                num = 1,
                id = 21001
            }
        },
        q_id = 30014,
        q_rewards = 
        {
            {
                ncs = 1,
                num = 5,
                id = 15
            },
            {
                ncs = 1,
                num = 100,
                id = 2
            },
            {
                ncs = 1,
                num = 1,
                id = 21001
            }
        },
        q_name ='每日在线15分钟',
        q_sort = 2,
        q_info = 1
    },
    {
        q_type = 3,	
        q_enter_button = 1024,
        q_show_rewards = 
        {
            { 
                ncs = 1, 
                num = 5, 
                id = 15
            },
            {
                ncs = 1, 
                num = 100,
                id = -2
            },
            {
                ncs = 1, 
                num = 1, 
                id = 21001
            }
        },
        q_id = 31014,
        q_rewards = 
        {
            {
                ncs = 1, 
                num = 5, 
                id = -15
            },
            {
                ncs = 1, 
                num = 100, 
                id = -2
            },
            {
                ncs = 1, 
                num = 1,
                id = 21001
            }
        },
        q_name ='每日在线15分钟', 
        q_sort = 2,
        q_info = 2,
        q_type = 3,
        q_enter_button = 1024,
        q_show_rewards = 
        {
            {
                ncs = 1,
                num = 5, 
                id = -15
            },
            {
                ncs = 1, 
                num = 100, 
                id = 2
            },
            {
                ncs = 1, 
                num = 1,
                id = 21001
            }
        },
        q_id = 32014,
        q_rewards = 
        {
            {
                ncs = 1, 
                num = 5, 
                id = -15
            },
            {
                ncs = 1, 
                num = 100, 
                id = -2
            },
        },
    }
}


return ActMessageTable
--endregion
