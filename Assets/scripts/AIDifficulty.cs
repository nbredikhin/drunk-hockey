public static class AIDifficulty
{
    public enum AIDifficultyLevel : int
    {
        LevelEasy = 0,
        LevelNormal,
        LevelHard,
        LevelHardAsBalls
    }

    // Уровень сложности AI
    static AIDifficultyLevel difficulty = AIDifficultyLevel.LevelEasy;

    // Максимальные скорости перемещения AI игрока
    static readonly float[] AIPlayerVelocityByDifficulty =
    {
        0.2f, // LevelEasy
        0.3f, // LevelNormal
        0.4f, // LevelHard
        0.5f  // LevelHardAsBalls
    };

    // Время реакции AI игрока на шайбу в миллисекундах
    static readonly int[] AIPlayerReactionDelayMSByDifficulty =
    {
        500, // LevelEasy
        250, // LevelNormal
        50,  // LevelHard
        0    // LevelHardAsBalls
    };

    // Вероятности "паники" у AI игрока. При "панике" AI игрок начинает
    // метаться к случайной точке на площадке. "Паника" -- это когда шайба
    // летает слишком быстро.
    static readonly float[] AIPlayerPanicChanceByDifficulty =
    {
        0.75f,
        0.5f,
        0.25f,
        0.0f
    };

    // Через это свойство происходит выставление уровня сложности, к примеру,
    // при закрытии сцены выбора сложности
    public static AIDifficultyLevel DifficultyLevel
    {
        get { return difficulty; }
        set { difficulty = value; }
    }

    // Максимальная скорость передвижения AI игрока для текущей сложности
    public static float AIPlayerVelocity
    {
        get { return AIPlayerVelocityByDifficulty[(int)difficulty]; }
    }

    // Время реакции AI игрока для текущей сложности
    public static int AIPlayerReactionDelayMS
    {
        get { return AIPlayerReactionDelayMSByDifficulty[(int)difficulty]; }
    }

    // Вероятность "паники" AI игрока для текущей сложности
    public static float AIPlayerPanicChance
    {
        get { return AIPlayerPanicChanceByDifficulty[(int)difficulty]; }
    }
}