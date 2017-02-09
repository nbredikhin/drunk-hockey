return {
    goalie = {
        initialState = "defend",
        states = {
            chase = {
                chase  = 0.0,
                defend = 1.0,
                attack = 0.0,
            },
            attack = {
                chase  = 0.05,
                defend = 0.6,
                attack = 0.35,
            },
            defend = {
                chase  = 0.01,
                defend = 0.7,
                attack = 0.29
            }
        }
    },
    bully = {
        initialState = "chase",
        states = {
            chase = {
                chase  = 0,
                defend = 1,
                attack = 1,
            },
            attack = {
                chase  = 0,
                defend = 1,
                attack = 0.5
            },
            defend = {
                chase  = 0,
                defend = 0.7,
                attack = 0.5
            }
        }
    },
    forward = {
        initialState = "attack",
        states = {
            chase = {
                chase  = 0,
                defend = 1,
                attack = 1,
            },
            attack = {
                chase  = 0,
                defend = 0.1,
                attack = 0.9
            },
            defend = {
                chase  = 0,
                defend = 0.2,
                attack = 0.8
            }
        }
    }
}