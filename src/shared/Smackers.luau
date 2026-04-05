return {
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
                Description = "Teeny-weeny-bitty smacker with less cooldown and faster animation.",
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
                    Description = "TOO HOT!!! Does a little magic trick and creates an area that burns players who touch it (except yourself)"
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
                    Description = "TOO COLD!!! Does an uppercut, and anyone who touches the smacker will be frozen."
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
        SmackerName = "Magnet",
        Shop = {
            Price = 2000,
            Information = {
                Description = "A magnet smacker. The smacker's handle holding the magnet.",
                Ability = {
                    Title = "Pull",
                    Description = "Pull players infront of you within a 50-stud range."
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
}