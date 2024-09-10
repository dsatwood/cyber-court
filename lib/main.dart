import 'package:flutter/material.dart';
import 'dart:math';

class Player {
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

  Enemy(this.name, this.health, this.attack, this.attackMessage);

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

// Helper to create enemies with variable stats within a range
Enemy createEnemy(String name, int minHP, int maxHP, int minAttack, int maxAttack, String attackMessage) {
  int health = minHP + Random().nextInt(maxHP - minHP + 1);
  int attack = minAttack + Random().nextInt(maxAttack - minAttack + 1);
  return Enemy(name, health, attack, attackMessage);
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

  // Create enemies with variable HP and attack ranges
  List<Enemy> alleyEnemies = [
    createEnemy("Cyber-Bum", 40, 60, 5, 8, "The Cyber-Bum hacks your nose"),
    createEnemy("Neon Junkie", 35, 50, 4, 6, "The Neon Junkie injects chaos into your mind"),
    createEnemy("Chrome Enforcer", 50, 70, 6, 9, "The Chrome Enforcer crushes you with his steel fists"),
    createEnemy("Street Hacker", 40, 55, 5, 7, "The Street Hacker overloads your neural circuits"),
    createEnemy("Rogue Cyberspider", 45, 60, 6, 8, "The Cyberspider bites into your cyberware"),
  ];

  List<Enemy> roboTenementsEnemies = [
    createEnemy("Scrap-Bot", 70, 90, 9, 12, "Scrap-Bot throws rusty gears at you"),
    createEnemy("Unemployed Butler Bot", 80, 100, 8, 10, "The Butler Bot throws a silver tray at your face"),
    createEnemy("Defective Welding Drone", 75, 95, 10, 13, "The Welding Drone sprays molten metal in your direction"),
  ];

  Enemy getFreshEnemy(List<Enemy> enemyList) {
    // Create a new fresh instance of an enemy
    Enemy baseEnemy = enemyList[Random().nextInt(enemyList.length)];
    return createEnemy(baseEnemy.name, baseEnemy.health, baseEnemy.health + 10, baseEnemy.attack, baseEnemy.attack + 3, baseEnemy.attackMessage);
  }

  void enterAlley() {
    if (!inCombat) {
      setState(() {
        currentEnemy = getFreshEnemy(alleyEnemies); // Always create a new enemy instance
        combatLog = "A ${currentEnemy!.name} appears from the shadows!";
        inCombat = true;
      });
    }
  }

  void enterRoboTenements() {
    if (!inCombat && player.level >= 3) {
      setState(() {
        currentEnemy = getFreshEnemy(roboTenementsEnemies); // Always create a new enemy instance
        combatLog = "You enter the Robo-Tenements and encounter a ${currentEnemy!.name}!";
        inCombat = true;
      });
    }
  }

  // Flee from combat (50% chance)
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cyberpunk Street at Night"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "You are standing in a neon-lit street. The city buzzes around you.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: inCombat ? null : enterAlley,
              child: const Text("Enter Alley"),
            ),
            if (player.level >= 3)
              ElevatedButton(
                onPressed: inCombat ? null : enterRoboTenements,
                child: const Text("Enter Robo-Tenements (Level 3+)"),
              ),
            ElevatedButton(
              onPressed: inCombat ? null : healAtClinic,
              child: const Text("Heal at digi-Clinic (20 credits)"),
            ),
            const SizedBox(height: 20),
            Text("Player Health: ${player.health}/${player.maxHealth}"),
            Text("Player Currency: ${player.currency} credits"),
            Text("Player Level: ${player.level}"),
            Text("XP: ${player.currentXP}/${player.xpToNextLevel}"),
            const SizedBox(height: 20),
            currentEnemy != null && inCombat
                ? Column(
                    children: [
                      Text("Enemy: ${currentEnemy!.name}"),
                      Text("Enemy Health: ${currentEnemy!.health}"),
                      ElevatedButton(
                        onPressed: attackEnemy,
                        child: const Text("Attack Enemy"),
                      ),
                      ElevatedButton(
                        onPressed: fleeCombat,
                        child: const Text("Flee"),
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 20),
            Text(combatLog),
          ],
        ),
      ),
    );
  }
}
