local _, ns = ...

local M = {
    STRANGE_DUST = 10940, SOUL_DUST = 11083, VISION_DUST = 11137,
    DREAM_DUST = 11176, ILLUSION_DUST = 16204,

    LESSER_MAGIC = 10938, GREATER_MAGIC = 10939,
    LESSER_ASTRAL = 10998, GREATER_ASTRAL = 11082,
    LESSER_MYSTIC = 11134, GREATER_MYSTIC = 11135,
    LESSER_NETHER = 11174, GREATER_NETHER = 11175,
    LESSER_ETERNAL = 16202, GREATER_ETERNAL = 16203,

    SMALL_GLIMMERING = 10978, LARGE_GLIMMERING = 11084,
    SMALL_GLOWING = 11138, LARGE_GLOWING = 11139,
    SMALL_RADIANT = 11177, LARGE_RADIANT = 11178,
    SMALL_BRILLIANT = 14343, LARGE_BRILLIANT = 14344,

    NEXUS_CRYSTAL = 20725,
}
ns.Mats = M

ns.Brackets = {
    { maxLevel = 10, dust = { M.STRANGE_DUST, 1, 2 }, essence = { M.LESSER_MAGIC, 1, 2 },
      shard = { M.SMALL_GLIMMERING, 1, 1 }, uncommonShard = false },
    { maxLevel = 15, dust = { M.STRANGE_DUST, 2, 3 }, essence = { M.GREATER_MAGIC, 1, 2 },
      shard = { M.SMALL_GLIMMERING, 1, 1 } },
    { maxLevel = 20, dust = { M.STRANGE_DUST, 4, 6 }, essence = { M.LESSER_ASTRAL, 1, 2 },
      shard = { M.SMALL_GLIMMERING, 1, 1 } },
    { maxLevel = 25, dust = { M.SOUL_DUST, 1, 2 }, essence = { M.GREATER_ASTRAL, 1, 2 },
      shard = { M.LARGE_GLIMMERING, 1, 1 } },
    { maxLevel = 30, dust = { M.SOUL_DUST, 2, 5 }, essence = { M.LESSER_MYSTIC, 1, 2 },
      shard = { M.SMALL_GLOWING, 1, 1 } },
    { maxLevel = 35, dust = { M.VISION_DUST, 1, 2 }, essence = { M.GREATER_MYSTIC, 1, 2 },
      shard = { M.LARGE_GLOWING, 1, 1 } },
    { maxLevel = 40, dust = { M.VISION_DUST, 2, 5 }, essence = { M.LESSER_NETHER, 1, 2 },
      shard = { M.SMALL_RADIANT, 1, 1 } },
    { maxLevel = 45, dust = { M.DREAM_DUST, 1, 2 }, essence = { M.GREATER_NETHER, 1, 2 },
      shard = { M.LARGE_RADIANT, 1, 1 } },
    { maxLevel = 50, dust = { M.DREAM_DUST, 2, 5 }, essence = { M.LESSER_ETERNAL, 1, 2 },
      shard = { M.SMALL_BRILLIANT, 1, 1 } },
    { maxLevel = 55, dust = { M.ILLUSION_DUST, 1, 2 }, essence = { M.GREATER_ETERNAL, 1, 2 },
      shard = { M.LARGE_BRILLIANT, 1, 1 }, crystal = { M.NEXUS_CRYSTAL, 1, 1 } },
    { maxLevel = 60, dust = { M.ILLUSION_DUST, 2, 5 }, essence = { M.GREATER_ETERNAL, 1, 3 },
      shard = { M.LARGE_BRILLIANT, 1, 1 }, crystal = { M.NEXUS_CRYSTAL, 1, 1 } },
}

ns.UncommonChances = {
    armor  = { dust = 0.75, essence = 0.20, shard = 0.05 },
    weapon = { dust = 0.20, essence = 0.75, shard = 0.05 },
}

ns.RareCrystalChance = 0.005

ns.EpicShardMaxLevel = 50
