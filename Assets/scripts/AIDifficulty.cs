public static class AIDifficulty
{
    public enum AIDifficultyLevel : int
    {
        LevelEasy = 0,
        LevelNormal,
        LevelHard,
        LevelHardAsBalls
    }

    static AIDifficultyLevel difficulty = AIDifficultyLevel.LevelEasy;

    static readonly float[] AIPlayerVelocityByDifficulty =
    {
        0.2f,
        0.3f,
        0.4f,
        0.5f
    };

    static readonly int[] AIPlayerReactionDelayMSByDifficulty =
    {
        500,
        250,
        50,
        0
    };

    static readonly float[] AIPlayerPanicChanceByDifficulty =
    {
        0.75f,
        0.5f,
        0.25f,
        0.0f
    };

    public static float AIPlayerVelocity
    {
        get { return AIPlayerVelocityByDifficulty[(int)difficulty]; }
    }

    public static int AIPlayerReactionDelayMS
    {
        get { return AIPlayerReactionDelayMSByDifficulty[(int)difficulty]; }
    }

    public static float AIPlayerPanicChance
    {
        get { return AIPlayerPanicChanceByDifficulty[(int)difficulty]; }
    }
}