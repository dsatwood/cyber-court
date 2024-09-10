import 'package:flutter/material.dart';
import 'dart:math';

class Player {
  // Player attributes
  int health;
  int maxHealth;
  int attack;
  int defense;
  int currency;
  int level;
  int currentXP;
  int xpToNextLevel;

  Player(this.health, this.attack, this.defense, this.currency)
      : maxHealth = health,
        level = 1,
        currentXP = 0,
        xpToNextLevel = 100;

  int attackEnemy() {
    return attack + Random().nextInt(5); // Slight random bonus
  }

  void takeDamage(int damage) {
    int finalDamage = max(0, damage - defense);
    health -= finalDamage;
  }

  void heal(int amount) {
    health = min(maxHealth, health + amount);
  }

  void resurrect() {
    health = maxHealth;
    currency = max(0, currency - 100);
  }

  void gainXP(int xp) {
    currentXP += xp;
    if (currentXP >= xpToNextLevel) {
      levelUp();
    }
  }

  void levelUp() {
    level++;
    currentXP = currentXP - xpToNextLevel;
    xpToNextLevel = (xpToNextLevel * 1.5).toInt();
    maxHealth += 10;
    attack += 2;
    defense += 1;
    health = maxHealth;
  }
}

class Enemy {
  String name;
  int health;
  int attack;
  String attackMessage;
  String imageAsset; // Image path

  Enemy(this.name, this.health, this.attack, this.attackMessage, this.imageAsset);

  int attackPlayer() {
    return attack + Random().nextInt(5); // Slight random bonus for enemies
  }

  void takeDamage(int damage) {
    health -= damage;
  }

  String getAttackText(int damage) {
    return "$attackMessage for $damage damage!";
  }
}

// Helper to create enemies with variable stats and images
Enemy createEnemy(String name, int minHP, int maxHP, int minAttack, int maxAttack, String attackMessage, String imageAsset) {
  int health = minHP + Random().nextInt(maxHP - minHP + 1);
  int attack = minAttack + Random().nextInt(maxAttack - minAttack + 1);
  return Enemy(name, health, attack, attackMessage, imageAsset);
}

void main() {
  runApp(const CyberpunkStreetGame());
}

class CyberpunkStreetGame extends StatelessWidget {
  const CyberpunkStreetGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CyberpunkStreetScreen(),
    );
  }
}

class CyberpunkStreetScreen extends StatefulWidget {
  const CyberpunkStreetScreen({Key? key}) : super(key: key);

  @override
  _CyberpunkStreetScreenState createState() => _CyberpunkStreetScreenState();
}

class _CyberpunkStreetScreenState extends State<CyberpunkStreetScreen> {
  Player player = Player(100, 10, 5, 50);
  Enemy? currentEnemy;
  String combatLog = "";
  bool inCombat = false;

  // Create enemies with variable HP, attack ranges, and images
  List<Enemy> alleyEnemies = [
    createEnemy("Cyber-Bum", 40, 60, 5, 8, "The Cyber-Bum hacks your nose", "assets/images/cyber_bum.png"),
    createEnemy("Neon Junkie", 35, 50, 4, 6, "The Neon Junkie injects chaos into your mind", "assets/images/neon_junkie.png"),
    createEnemy("Chrome Enforcer", 50, 70, 6, 9, "The Chrome Enforcer crushes you with his steel fists", "assets/images/chrome_enforcer.png"),
    createEnemy("Street Hacker", 40, 55, 5, 7, "The Street Hacker overloads your neural circuits", "assets/images/street_hacker.png"),
    createEnemy("Rogue Cyberspider", 45, 60, 6, 8, "The Cyberspider bites into your cyberware", "assets/images/rogue_cyberspider.png"),
  ];

  List<Enemy> roboTenementsEnemies = [
    createEnemy("Scrap-Bot", 70, 90, 9, 12, "Scrap-Bot throws rusty gears at you", "assets/images/scrap_bot.png"),
    createEnemy("Unemployed Butler Bot", 80, 100, 8, 10, "The Butler Bot throws a silver tray at your face", "assets/images/butler_bot.png"),
    createEnemy("Defective Welding Drone", 75, 95, 10, 13, "The Welding Drone sprays molten metal in your direction", "assets/images/welding_drone.png"),
  ];

  Enemy getFreshEnemy(List<Enemy> enemyList) {
    // Create a new fresh instance of an enemy
    Enemy baseEnemy = enemyList[Random().nextInt(enemyList.length)];
    return createEnemy(baseEnemy.name, baseEnemy.health, baseEnemy.health + 10, baseEnemy.attack, baseEnemy.attack + 3, baseEnemy.attackMessage, baseEnemy.imageAsset);
  }

  void enterAlley() {
    if (!inCombat) {
      setState(() {
        currentEnemy = getFreshEnemy(alleyEnemies);
        combatLog = "A ${currentEnemy!.name} appears from the shadows!";
        inCombat = true;
      });
    }
  }

  void enterRoboTenements() {
    if (!inCombat && player.level >= 3) {
      setState(() {
        currentEnemy = getFreshEnemy(roboTenementsEnemies);
        combatLog = "You enter the Robo-Tenements and encounter a ${currentEnemy!.name}!";
        inCombat = true;
      });
    }
  }

  void fleeCombat() {
    if (inCombat) {
      setState(() {
        int fleeChance = Random().nextInt(100);
        if (fleeChance < 50) {
          combatLog = "You successfully fled the battle!";
          inCombat = false;
        } else {
          combatLog = "You failed to flee!";
          int enemyDamage = currentEnemy!.attackPlayer();
          player.takeDamage(enemyDamage);
          combatLog += "\n${currentEnemy!.getAttackText(enemyDamage)}";
          if (player.health <= 0) {
            combatLog += "\nYou were defeated by the ${currentEnemy!.name}!";
            player.resurrect();
            inCombat = false;
            combatLog += "\nYou are resurrected at the digi-Clinic but lost 100 currency!";
          }
        }
      });
    }
  }

  void attackEnemy() {
    if (currentEnemy != null) {
      setState(() {
        int playerDamage = player.attackEnemy();
        currentEnemy!.takeDamage(playerDamage);
        combatLog = "You hit the ${currentEnemy!.name} for $playerDamage damage!";
        if (currentEnemy!.health > 0) {
          int enemyDamage = currentEnemy!.attackPlayer();
          player.takeDamage(enemyDamage);
          combatLog += "\n${currentEnemy!.getAttackText(enemyDamage)}";
          if (player.health <= 0) {
            combatLog += "\nYou were defeated by the ${currentEnemy!.name}!";
            player.resurrect();
            inCombat = false;
            combatLog += "\nYou are resurrected at the digi-Clinic but lost 100 currency!";
          }
        } else {
          int loot = Random().nextInt(20) + 5; // Lowered XP and loot
          int xp = Random().nextInt(30) + 20;
          player.currency += loot;
          player.gainXP(xp);
          combatLog = "You defeated the ${currentEnemy!.name} and found $loot credits and $xp XP!";
          currentEnemy = null;
          inCombat = false;
        }
      });
    }
  }

  void healAtClinic() {
    if (!inCombat) {
      setState(() {
        if (player.currency >= 20) {
          player.heal(30);
          player.currency -= 20;
          combatLog = "You healed 30 health points at the digi-Clinic for 20 credits!";
        } else {
          combatLog = "Not enough credits to heal!";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cyberpunk Street at Night"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (inCombat && currentEnemy != null)
                Column(
                  children: [
                    Container(
                      width: screenWidth * 0.37, // Half the size of previous
                      height: screenHeight * 0.22,
                      child: Image.asset(currentEnemy!.imageAsset, fit: BoxFit.contain),
                    ),
                    Text(
                      "Enemy: ${currentEnemy!.name}",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Enemy Health: ${currentEnemy!.health}",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              if (!inCombat)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Alley Option
                        Stack(
                          children: [
                            Container(
                              width: screenWidth * 0.5, // Half size
                              height: screenHeight * 0.3,
                              child: Image.asset("assets/images/cyberpunk_street.png", fit: BoxFit.contain),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
                                  onPressed: inCombat ? null : enterAlley,
                                  child: const Text("Enter Alley"),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        // Robo-Tenements Option
                        if (player.level >= 3)
                          Stack(
                            children: [
                              Container(
                                width: screenWidth * 0.6, // Half size
                                height: screenHeight * 0.4,
                                child: Image.asset("assets/images/robo_tenements.png", fit: BoxFit.contain),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ElevatedButton(
                                    onPressed: inCombat ? null : enterRoboTenements,
                                    child: const Text("Enter Robo-Tenements"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Digi-Clinic Option
                    Stack(
                      children: [
                        Container(
                          width: screenWidth * 0.5, // Half size
                          height: screenHeight * 0.3,
                          child: Image.asset("assets/images/digi_clinic.png", fit: BoxFit.contain),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              onPressed: inCombat ? null : healAtClinic,
                              child: const Text("Heal at digi-Clinic"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Text(
                "Player Health: ${player.health}/${player.maxHealth}",
                textAlign: TextAlign.center,
              ),
              Text(
                "Player Currency: ${player.currency} credits",
                textAlign: TextAlign.center,
              ),
              Text(
                "Player Level: ${player.level}",
                textAlign: TextAlign.center,
              ),
              Text(
                "XP: ${player.currentXP}/${player.xpToNextLevel}",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (currentEnemy != null && inCombat)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: attackEnemy,
                      child: const Text("Attack Enemy"),
                    ),
                    ElevatedButton(
                      onPressed: fleeCombat,
                      child: const Text("Flee"),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Text(
                combatLog,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
