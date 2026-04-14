local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
TEMPLATE:
{
        SmackerName = "SMACKER_NAME",
        Shop = {
            Price = 0,
            Information = {
                Description = "SMACKER_DESCRIPTION",
                Ability = {
                    Title = "ABILITY_TITLE",
                    Description = "ABILITY_DESCRIPTION"
                },
                Damage = "7", -- make these the same as the SMACK stats below
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            KnockbackVulnerability = 1 -- (optional*)
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Smash",
            AttackDuration = 2,
            AttackDebounce = 10,
        }
    },
]]

return {
    {
        SmackerName = "Nothing",
        Shop = {
            Price = 0,
            Information = {
                Description = "\"april fools\"!!! it's there bro, look closer (source: trust me)",
                Ability = {
                    Title = "R U FOR REAL????",
                    Description = "i won't dedicate 10 seconds of my life to write text for something nonexistent"
                },
                Damage = "do you expect damage from the absence of a smacker",
                KnockbackSpeed = "insert knockbackspeed?",
                KnockbackUp = "insert knockbackup???",
                Caption = {
                    Text = "LIMITED!!!",
                    Color = Color3.fromRGB(255, 255, 0)
                }
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Smash",
            AttackDuration = 2,
            AttackDebounce = 10,
        }
    },
    {
        SmackerName = "Tutorial",
        Shop = {
            Price = 0,
            Information = {
                Description = "april fools!!! free for new players to use!",
                Ability = {
                    Title = "free tutoring",
                    Description = "you may lack brainpower to process how smacking should be properly executed, hence why this smacker was made."
                },
                Damage = "10",
                KnockbackSpeed = "40",
                KnockbackUp = "20",
                Caption = {
                    Text = "LIMITED!!!",
                    Color = Color3.fromRGB(255, 255, 0)
                }
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
            Hit = function(AttackerPlayer : Player, VictimCharacter)
                local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)

                ReplicatedStorage.Remotes.Distract:FireClient(AttackerPlayer)
                if VictimPlayer then
                    ReplicatedStorage.Remotes.Distract:FireClient(VictimPlayer)
                end
            end
        },
        Attack = {
            AttackName = "Smash",
            AttackDuration = 2,
            AttackDebounce = 10,
        }
    },
    {
        SmackerName = "Default",
        Shop = {
            Price = 0,
            Information = {
                Description = "A default smacker.",
                Ability = {
                    Title = "Smash",
                    Description = "Smash other players, dealing 35 damage"
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Smash",
            AttackDuration = 2,
            AttackDebounce = 10,
        }
    },
    {
        SmackerName = "Extended",
        Shop = {
            Price = 10,
            Information = {
                Description = "A LONGGGG smacker. You have longer reach but vulnerable to players in range.",
                Ability = {
                    Title = "Long Smash",
                    Description = "Default smash with your longer smacker. Longer windup but faster smash."
                },
                Damage = "6",
                KnockbackSpeed = "45",
                KnockbackUp = "20",
            }
        },
        Smack = {
            Damage = 6,
            KnockbackSpeed = 45,
            KnockbackUp = 20,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Long Smash",
            AttackDuration = 2,
            AttackDebounce = 20,
        }
    },
    {
        SmackerName = "Tank",
        Shop = {
            Price = 25,
            Information = {
                Description = "A SUPER-DUPER big smacker. Smack has longer windup and is SUPER-DUPER parryable.",
                Ability = {
                    Title = "Heavy Smash",
                    Description = "Smash but with your big smacker. A basic 70-damage smash with a really long windup."
                },
                Damage = "10",
                KnockbackSpeed = "45",
                KnockbackUp = "45",
            }
        },
        Smack = {
            Damage = 10,
            KnockbackSpeed = 45,
            KnockbackUp = 45,
            AnimationSpeed = .25,
        },
        Attack = {
            AttackName = "Heavy Smash",
            AttackDuration = 8,
            AttackDebounce = 40,
        }
    },
    {
        SmackerName = "Mini",
        Shop = {
            Price = 25,
            Information = {
                Description = "Teeny-weeny-bitty smacker with less cooldown and faster animation. Try if you like challenges (broken hitbox, small damage small knockback).",
                Ability = {
                    Title = "Light Smash",
                    Description = "Mini smash, shorter windup paired with less damage."
                },
                Damage = "2",
                KnockbackSpeed = "4",
                KnockbackUp = "4",
            }
        },
        Smack = {
            Damage = 2,
            KnockbackSpeed = 6,
            KnockbackUp = 4,
            AnimationSpeed = 2,
        },
        Attack = {
            AttackName = "Light Smash",
            AttackDuration = 1,
            AttackDebounce = 5,
        }
    },
    {
        SmackerName = "Fire",
        Shop = {
            Price = 50,
            Information = {
                Description = "A hot smacker only the wielder can hold, since it's too hot.",
                Ability = {
                    Title = "Too Hot",
                    Description = "TOO HOT!!! Does a little magic trick and creates an area that burns players who touch it (except yourself). Deals 32 damage total, 4 damage per second over the span of 8 seconds."
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Too Hot",
            AttackDuration = 2,
            AttackDebounce = 15,
        }
    },
    {
        SmackerName = "Ice",
        Shop = {
            Price = 75,
            Information = {
                Description = "Cold, still usable smacker. Kinda...",
                Ability = {
                    Title = "Too Cold",
                    Description = "TOO COLD!!! Does an uppercut, and anyone who touches the smacker will be frozen for 5 seconds."
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Too Cold",
            AttackDuration = 2,
            AttackDebounce = 15,
        }
    },
    {
        SmackerName = "Spear",
        Shop = {
            Price = 100,
            Information = {
                Description = "A spear? It's not a smacker but okay...",
                Ability = {
                    Title = "Throw",
                    Description = "Throw your \"smacker\" to the player and watch it fly like a bird, redirects itself and deals 20 HP."
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Throw",
            AttackDuration = 5,
            AttackDebounce = 5,
        }
    },
    {
        SmackerName = "Dice",
        Shop = {
            Price = 150,
            Information = {
                Description = "Do you like gambling? I don't.",
                Ability = {
                    Title = "Random",
                    Description = "[PASSIVE] Random damage + random knockback."
                },
                Damage = "3-11",
                KnockbackSpeed = "5-55",
                KnockbackUp = "5-25",
            }
        },
        Smack = {
            Damage = function()
                return math.random(3, 11)
            end,
            KnockbackSpeed = function()
                return math.random(5, 55)
            end,
            KnockbackUp = function()
                return math.random(5, 25)
            end,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Random",
            AttackDuration = 0,
            AttackDebounce = 10,
        }
    },
    {
        SmackerName = "Dash",
        Shop = {
            Price = 250,
            Information = {
                Description = "Weirdly shaped smacker, powerful if you use it correctly.",
                Ability = {
                    Title = "Dash",
                    Description = "You dash... Get it? Walk somewhere, you dash that way."
                },
                Damage = "8",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 8,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Dash",
            AttackDuration = .5,
            AttackDebounce = 2,
        }
    },
    {
        SmackerName = "Stealth",
        Shop = {
            Price = 500,
            Information = {
                Description = "This description might not be visible.",
                Ability = {
                    Title = "Camouflage",
                    Description = "Turns you 95% invisible, you probably know what would happen if it was 100%."
                },
                Damage = "8",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 8,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Camouflage",
            AttackDuration = .5,
            AttackDebounce = 15,
        }
    },
    {
        SmackerName = "Cannonball",
        Shop = {
            Price = 600,
            Information = {
                Description = "A smacker, with a cannonball as a head. Be a real-time pirate.",
                Ability = {
                    Title = "Shoot",
                    Description = "Shoot your lethal cannonball, once it hits a player, it explodes and deals 35 damage. Dodgable."
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Shoot",
            AttackDuration = 1,
            AttackDebounce = 10,
        }
    },
    {
        SmackerName = "Glass",
        Shop = {
            Price = 750,
            Information = {
                Description = "Glass smacker. High damage and insane knockback, but with a catch.",
                Ability = {
                    Title = "Vulnerable",
                    Description = "[PASSIVE] You take 2x knockback from everything. High risk, high reward."
                },
                Damage = "12",
                KnockbackSpeed = "50",
                KnockbackUp = "35",
            }
        },
        Smack = {
            Damage = 12,
            KnockbackSpeed = 55,
            KnockbackUp = 35,
            KnockbackVulnerability = 2,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Vulnerable",
            AttackDuration = 2,
            AttackDebounce = 10,
        },
    },
    {
        SmackerName = "Landmine",
        Shop = {
            Price = 1000,
            Information = {
                Description = "Landmine-shaped smacker. This smacker's concept was once interesting.",
                Ability = {
                    Title = "Explode",
                    Description = "Lunges forward and if someone touches your landmine, you take 40HP and they take 60 HP"
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Explode",
            AttackDuration = .5,
            AttackDebounce = 15,
        }
    },
    {
        SmackerName = "Blink",
        Shop = {
            Price = 1250,
            Information = {
                Description = "A smacker with the image of eyes in each surface.",
                Ability = {
                    Title = "Blink",
                    Description = "Teleports to the closest player, but you can't smack for 1.75s"
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Teleport",
            AttackDuration = .5,
            AttackDebounce = 5,
        }
    },
    {
        SmackerName = "Whip",
        Shop = {
            Price = 1500,
            Information = {
                Description = "A whip-shaped smacker, interesting concept along with landmine. Don't try to do your interesting ideas with the \"smacker\".",
                Ability = {
                    Title = "Big Whip",
                    Description = "Do a big whip, deals 40 damage."
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Big Whip",
            AttackDuration = .5,
            AttackDebounce = 5,
        }
    },
    {
        SmackerName = "Magnet",
        Shop = {
            Price = 2000,
            Information = {
                Description = "A magnet smacker. The smacker's handle holding the magnet.",
                Ability = {
                    Title = "Pull",
                    Description = "Pull players infront of you within a 100-stud range, targetted players are stunned for 2 seconds. Good for crowd control."
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Pull",
            AttackDuration = 1,
            AttackDebounce = 10,
        }
    },
    {
        SmackerName = "Build",
        Shop = {
            Price = 2500,
            Information = {
                Description = "Johnny is building a nice platform, I wonder what's gonna happen to Johnny.",
                Ability = {
                    Title = "Construct",
                    Description = "Make a circle-shaped platform that lasts for 10 seconds, tower up to the lobby yo!"
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
                Caption = {
                    Text = "NEW!!!",
                    Color = Color3.fromRGB(0, 247, 255)
                }
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Construct",
            AttackDuration = 1,
            AttackDebounce = 5,
        }
    },
    {
        SmackerName = "Mirror",
        Shop = {
            Price = 3000,
            Information = {
                Description = "A handle handling a mirror. No realistic reflect effect to reflect.",
                Ability = {
                    Title = "Reflect",
                    Description = "Turns your handle handling mirror into a mirror that reflects effects. You reflect knockback effects from attacking attackers for 2 seconds."
                },
                Damage = "7",
                KnockbackSpeed = "30",
                KnockbackUp = "15",
            }
        },
        Smack = {
            Damage = 7,
            KnockbackSpeed = 30,
            KnockbackUp = 15,
            AnimationSpeed = 1,
        },
        Attack = {
            AttackName = "Reflect",
            AttackDuration = 2,
            AttackDebounce = 10,
        }
    },
}