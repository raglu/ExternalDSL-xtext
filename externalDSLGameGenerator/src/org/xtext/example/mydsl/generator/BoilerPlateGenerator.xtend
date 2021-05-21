package org.xtext.example.mydsl.generator

import org.eclipse.xtext.generator.IFileSystemAccess2

class BoilerPlateGenerator {

	def static generateCode(IFileSystemAccess2 fsa) {
		generateCommand(fsa);
		generateGame(fsa);
		generateHostileNPC(fsa);
		generateItem(fsa);
		generateNPC(fsa);
		generateParser(fsa);
		generatePath(fsa);
		generatePlayer(fsa);
		generateRoom(fsa);
		generateWeapon(fsa);

	}

	def static generateCommand(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/Command.java",
			'''
				package gameDSL;
				
				public class Command {
				    private String firstWord;
				    private String secondWord;
				
				    public Command(String firstWord, String secondWord) {
				        this.firstWord = firstWord;
				        this.secondWord = secondWord;
				    }
				
				    public String getFirstWord() {
				        return firstWord;
				    }
				
				    public String getSecondWord() {
				        return secondWord;
				    }
				}
				
			'''
		)
	}

	def static generateGame(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/Game.java",
			'''
			package gameDSL;
			
			import java.util.ArrayList;
			
			public class Game {
			
			    private String gameWorld;
			    private boolean playing;
			
			    private final GameRules gameRules;
			    ArrayList<Room> rooms;
			    ArrayList<Player> players;
			    ArrayList<NPC> npcs;
			
			    public Game(String gameWorldName) {
			        gameRules = new GameRules(this);
			
			        gameWorld = gameWorldName;
			
			        rooms = EntityGenerator.generateRooms();
			        players = EntityGenerator.generatePlayers();
			        npcs = EntityGenerator.generateNPCs();
			
			    }
			
			    public void play() {
			
			        playing = true;
			
			        System.out.println("Welcome to " + gameWorld);
			
			        while (playing) {
			            for (Player player : players) {
			                printSituation(player);
			                Command command = Parser.getCommand(player.getName());
			                processPlayerCommand(player, command);
			            }
			            for (NPC npc : npcs) {
			                processNPC(npc);
			            }
			            gameRules.checkRules();
			        }
			        System.out.println("Thank you for playing. Good bye");
			    }
			
			    private void printSituation(Player player) {
			        System.out.println("\n" + player.getName() + " is now in " + player.getCurrentRoom().getName());
			        if (player.isInCombat())
			            System.out.println(player.getName() + " is in combat with " + player.getTargetHostileNPC().getName());
			        System.out.println("- Exits in this room: " + player.getCurrentRoom().getExits());
			        System.out.println("- Items in this room: " + player.getCurrentRoom().getItemNames());
			        System.out.println("- NPCs in this room: " + player.getCurrentRoom().getNpcNames());
			    }
			
			    private void processPlayerCommand(Player player, Command command) {
			
			        String firstWord = command.getFirstWord();
			        String secondWord = command.getSecondWord();
			
			        switch (firstWord) {
			            case "quit" -> quit();
			            case "help" -> printHelp();
			            case "go" -> goPath(player, secondWord);
			            case "inventory" -> printInventory(player);
			            case "equip" -> equipItem(player, secondWord);
			            case "take" -> takeItem(player, secondWord);
			            case "drop" -> dropItem(player, secondWord);
			            case "attack" -> attackNPC(player, secondWord);
			            default -> System.out.println("I don't know what you mean...");
			        }
			    }
			
			    private void quit() {
			        System.out.println("Quitting game...");
			        playing = false;
			    }
			
			    private void printHelp() {
			        System.out.println("Possible commands:");
			        System.out.println("quit  help  go  inventory  equip  take  drop  attack");
			    }
			
			    private void goPath(Player player, String pathName) {
			        if (player.isInCombat()) {
			            if (!player.getTargetHostileNPC().isEscapable()){
			                System.out.println(player.getName() + " cannot escape " + player.getTargetHostileNPC().getName());
			                return;
			            }
			        }
			
			        if (pathName == null) {
			            System.out.println("Go where?");
			            return;
			        }
			
			        Path chosenPath = player.getCurrentRoom().findPath(pathName);
			
			        if (chosenPath == null) {
			            System.out.println(player.getName() + " can't go that way");
			            return;
			        }
			
			        Item requirement = chosenPath.getRequirement();
			        if (requirement != null) {
			            if (!player.hasItem(requirement.getName())) {
			                System.out.println(player.getName() + " need a " + requirement.getName() + " to enter");
			                return;
			            }
			        }
					
			        player.setInCombat(false);
			        player.setTargetHostileNPC(null);
			
			        player.setCurrentRoom(chosenPath.getDestination());
			        System.out.println(player.getName() + " went through " + chosenPath.getPathName());
			    }
			
			    private void printInventory(Player player) {
			        ArrayList<Item> inventory = player.getInventory();
			        System.out.print("Inventory: ");
			        for (Item i : inventory) {
			            System.out.print(i.getName() + ", ");
			        }
			        Item equipped = player.getEquipped();
			        System.out.print("\nEquipped: ");
			        if (equipped != null)
			            System.out.print(equipped.getName());
			        System.out.println();
			    }
			
			    private void equipItem(Player player, String itemName) {
			        if (itemName == null) {
			            System.out.println("Equip what?");
			            return;
			        }
			
			        Item item = player.findItem(itemName);
			
			        if (item == null) {
			            System.out.println(player.getName() + " does not have that item");
			            return;
			        }
			        if (!(item instanceof Weapon)) {
			            System.out.println(player.getName() + " can't equip that item");
			            return;
			        }
			        player.setEquipped(item);
			        System.out.println(player.getName() + " equipped " + item.getName());
			    }
			
			    private void takeItem(Player player, String itemName) {
			        if (itemName == null) {
			            System.out.println("Take what?");
			            return;
			        }
			
			        Item item = player.getCurrentRoom().findItem(itemName);
			
			        if (item == null) {
			            System.out.println(player.getName() + " can't take that");
			            return;
			        }
			
			        int currentCarryWeight = 0;
			
			        for (Item inventoryItem : player.getInventory()) {
			            currentCarryWeight += inventoryItem.getWeight();
			        }
			
			        if (player.getCarryCapacity() < currentCarryWeight + item.getWeight()) {
			            System.out.println(player.getName() + " cannot carry anymore items");
			            return;
			        }
			
			        player.getCurrentRoom().removeItem(item);
			        player.addItem(item);
			        System.out.println(player.getName() + " took " + item.getName());
			
			    }
			
			    private void dropItem(Player player, String itemName) {
			        if (itemName == null) {
			            System.out.println("Drop what?");
			            return;
			        }
			
			        Item item = player.findItem(itemName);
			
			        if (item == null) {
			            System.out.println(player.getName() + " does not have that item");
			            return;
			        }
			
			        player.getCurrentRoom().addItem(item);
			        player.removeItem(item);
			        System.out.println(player.getName() + " dropped " + item.getName());
			    }
			
			    private void attackNPC(Player player, String npcName) {
			        Weapon equippedWeapon = (Weapon) player.getEquipped();
			        if (equippedWeapon == null) {
			            System.out.println(player.getName() + " can't attack without a weapon equipped");
			            return;
			        }
			
			        if (npcName == null) {
			            System.out.println("Attack what?");
			            return;
			        }
			
			        NPC targetNPC = player.currentRoom.findNPC(npcName);
			
			        if (targetNPC == null) {
			            System.out.println("That NPC is not here");
			            return;
			        }
			
			        if (!(targetNPC instanceof HostileNPC)) {
			            System.out.println("Non-hostile NPCs cannot be attacked");
			            return;
			        }
			
			        HostileNPC targetHostileNPC = (HostileNPC) targetNPC;
			        targetHostileNPC.reduceHealth(equippedWeapon.getDamage());
			        equippedWeapon.reduceDurability(1);
			
			        player.setInCombat(true);
			        player.setTargetHostileNPC(targetHostileNPC);
			        targetHostileNPC.setInCombat(true);
			        targetHostileNPC.setTargetPlayer(player);
			
			        System.out.println(player.getName() + " attacked " + targetHostileNPC.getName());
			        System.out.println(targetHostileNPC.getName() + " has " + targetHostileNPC.getHealth() + " health");
			        if (equippedWeapon.getDurability() ==0)
			            System.out.println(player.getName() + "equipped weapon broke");
			    }
			
			    private void processNPC(NPC npc) {
			        if (npc instanceof HostileNPC) {
			            processHostileNPC((HostileNPC) npc);
			        }
			        //TODO wtf do none-hostile NPCs do?
			    }
			
			    private void processHostileNPC(HostileNPC hostileNPC) {
			        if(hostileNPC.getHealth() <=  0){
			            System.out.println(hostileNPC.getName() + " died");
			            npcs.remove(hostileNPC);
			            hostileNPC.getCurrentRoom().removeNPC(hostileNPC);
			        }
			
			        if (hostileNPC.isInCombat()) {
			            hostileNPC.attackPlayer();
			            Player targetPlayer = hostileNPC.getTargetPlayer();
			            System.out.println(hostileNPC.getName() + " attacked " + targetPlayer.getName());
			            System.out.println(targetPlayer.getName() + " has " + targetPlayer.getHealth() + " health");
			            return;
			        }
			
			        if (hostileNPC.isAggressive() && hostileNPC.getCurrentRoom().hasPlayers()) {
			            Player targetPlayer = hostileNPC.getCurrentRoom().getRandomPlayer();
			            targetPlayer.setInCombat(true);
			            targetPlayer.setTargetHostileNPC(hostileNPC);
			            hostileNPC.setInCombat(true);
			            hostileNPC.setTargetPlayer(targetPlayer);
			
			            System.out.println(hostileNPC.getName() + " has engaged in combat with " + targetPlayer.getName());
			        }
			    }
			
			    public void gameOver() {
			        playing = false;
			        System.out.println("GameOver");
			    }
			
			    public void winGame() {
			        System.out.println("You won the game!");
			    }
			}
			'''
		)
	}

	def static generateHostileNPC(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/HostileNPC.java",
			'''
			package gameDSL;
			
			public abstract class HostileNPC extends NPC {
			    protected boolean escapable;
			    protected int health;
			    protected int damage;
			    private boolean inCombat = false;
			    private Player targetPlayer = null;
			    private boolean aggressive;
			
			    public HostileNPC(Room currentRoom, String name, boolean escapable, int health, int damage) {
			        super(currentRoom, name);
			        this.escapable = escapable;
			        this.health = health;
			        this.damage = damage;
			        this.aggressive = false;
			    }
			
			    public HostileNPC(Room currentRoom, String name, boolean escapable, int health, int damage, boolean aggressive) {
			        super(currentRoom, name);
			        this.escapable = escapable;
			        this.health = health;
			        this.damage = damage;
			        this.aggressive = aggressive;
			    }
			
			    public boolean isEscapable() {
			        return escapable;
			    }
			
			    public int getHealth() {
			        return health;
			    }
			
			    public void reduceHealth(int damage) {
			        health -= damage;
			    }
			
			    public void attackPlayer() {
			        targetPlayer.reduceHealth(damage);
			    }
			
			    public boolean isAggressive() {
			        return aggressive;
			    }
			
			    public boolean isInCombat() {
			        return inCombat;
			    }
			
			    public void setInCombat(boolean inCombat) {
			        this.inCombat = inCombat;
			    }
			
			    public Player getTargetPlayer() {
			        return targetPlayer;
			    }
			
			    public void setTargetPlayer(Player targetPlayer) {
			        this.targetPlayer = targetPlayer;
			    }
			}
			
			'''
		)
	}

	def static generateItem(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/Item.java",
			'''
			package gameDSL;
			
			public abstract class Item {
			
			    protected String name;
			    protected int weight;
			
			    public Item(String name) {
			        this.name = name;
			        this.weight = 0;
			    }
			
			    public Item(String name, int weight) {
			        this.name = name;
			        this.weight = weight;
			    }
			
			    public String getName() {
			        return name;
			    }
			
			    public int getWeight() {
			        return weight;
			    }
			}
			'''
		)
	}

	def static generateNPC(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/NPC.java",
			'''
			package gameDSL;
			
			public abstract class NPC {
			
			    private String name;
			    private Room currentRoom;
			
			    public NPC(Room currentRoom, String name) {
			        this.name = name;
			        this.currentRoom = currentRoom;
			
			        currentRoom.addNPC(this);
			    }
			
			    public String getName() {
			        return name;
			    }
			
			    public void setCurrentRoom(Room newRoom) {
			        currentRoom.removeNPC(this);
			        currentRoom = newRoom;
			        currentRoom.addNPC(this);
			    }
			
			    public Room getCurrentRoom() {
			        return currentRoom;
			    }
			}
			'''
		)
	}

	def static generateParser(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/Parser.java",
			'''
			package gameDSL;
			
			import java.io.BufferedReader;
			import java.io.InputStreamReader;
			import java.util.StringTokenizer;
			
			public class Parser {
			
			    public static Command getCommand(String caller) {
			        String inputLine = "";
			        String word1;
			        String word2;
			
			        System.out.print(caller + "> ");
			
			        BufferedReader reader =
			                new BufferedReader(new InputStreamReader(System.in));
			        try {
			            inputLine = reader.readLine();
			        } catch (java.io.IOException exc) {
			            System.out.println("There was an error during reading: "
			                    + exc.getMessage());
			        }
			
			        StringTokenizer tokenizer = new StringTokenizer(inputLine);
			
			        if (tokenizer.hasMoreTokens())
			            word1 = tokenizer.nextToken();
			        else
			            word1 = "";
			
			        if (tokenizer.hasMoreTokens())
			            word2 = tokenizer.nextToken();
			        else
			            word2 = null;
			
			        while (tokenizer.hasMoreTokens())
			            word2 += " "+ tokenizer.nextToken();
			
			        return new Command(word1, word2);
			    }
			
			}
			'''
		)
	}

	def static generatePath(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/Path.java",
			'''
			package gameDSL;
			
			public class Path {
			    private String pathName;
			    private Room destination;
			    private Item requirement;
			
			    public Path(Room destination, String pathName, Item requirement) {
			        this.pathName = pathName;
			        this.destination = destination;
			        this.requirement = requirement;
			    }
			
			    public Path(Room destination, String pathName) {
			        this.pathName = pathName;
			        this.destination = destination;
			        this.requirement = null;
			    }
			
			    public String getPathName() {
			        return pathName;
			    }
			
			    public Room getDestination() {
			        return destination;
			    }
			
			    public Item getRequirement() {
			        return requirement;
			    }
			}
			'''
		)
	}

	def static generatePlayer(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/Player.java",
			'''
			package gameDSL;
			
			import java.util.ArrayList;
			
			public class Player {
			
			    protected String name;
			    protected int health;
			    protected int carryCapacity;
			    protected ArrayList<Item> inventory;
			    protected Item equipped;
			    protected Room currentRoom;
			
			    private boolean inCombat = false;
			
			    private HostileNPC targetHostileNPC = null;
			
			    public Player(Room currentRoom, String name, int health, int carryCapacity) {
			        this.currentRoom = currentRoom;
			        this.name = name;
			        this.health = health;
			        this.carryCapacity = carryCapacity;
			        this.inventory = new ArrayList<>();
			
			        currentRoom.addPlayer(this);
			    }
			
			    public Room getCurrentRoom() {
			        return currentRoom;
			    }
			
			    public void setCurrentRoom(Room newRoom) {
			        currentRoom.removePlayer(this);
			        currentRoom = newRoom;
			        currentRoom.addPlayer(this);
			    }
			
			    public String getName() {
			        return name;
			    }
			
			    public int getHealth() {
			        return health;
			    }
			
			    public int getCarryCapacity() {
			        return carryCapacity;
			    }
			
			    public ArrayList<Item> getInventory() {
			        return inventory;
			    }
			
			    public Item getEquipped() {
			        return equipped;
			    }
			
			    public void setEquipped(Item item) {
			        equipped = item;
			    }
			
			    public void addItem(Item item) {
			        inventory.add(item);
			    }
			
			    public Item findItem(String itemName) {
			        for (Item i : inventory) {
			            if (i.getName().equalsIgnoreCase(itemName))
			                return i;
			        }
			        return null;
			    }
			
			    public void removeItem(Item item) {
			        inventory.remove(item);
			        if (equipped == item)
			            equipped = null;
			    }
			
			    public boolean hasItem(String itemName) {
			        for (Item i : inventory) {
			            if (i.getName().equalsIgnoreCase(itemName))
			                return true;
			        }
			        return false;
			    }
			
			    public void reduceHealth(int damage) {
			        health -= damage;
			    }
			
			    public boolean isInCombat() {
			        return inCombat;
			    }
			
			    public void setInCombat(boolean inCombat) {
			        this.inCombat = inCombat;
			    }
			
			    public HostileNPC getTargetHostileNPC() {
			        return targetHostileNPC;
			    }
			
			    public void setTargetHostileNPC(HostileNPC targetHostileNPC) {
			        this.targetHostileNPC = targetHostileNPC;
			    }
			}
			'''
		)
	}

	def static generateRoom(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/Room.java",
			'''
			package gameDSL;
			
			import java.util.ArrayList;
			import java.util.Random;
			
			public abstract class Room {
			    protected String name;
			    protected ArrayList<Path> paths;
			    protected ArrayList<Item> items;
			    protected ArrayList<NPC> npcs;
			    protected ArrayList<Player> players;
			
			    public Room(String name) {
			        this.name = name;
			        this.paths = new ArrayList<>();
			        this.items = new ArrayList<>();
			        this.npcs = new ArrayList<>();
			        this.players = new ArrayList<>();
			    }
			
			    public abstract void setPaths();
			
			    public abstract void setItems();
			
			    public NPC findNPC(String npcName) {
			        for (NPC n : npcs) {
			            if (n.getName().equalsIgnoreCase(npcName))
			                return n;
			        }
			        return null;
			    }
			
			    public Path findPath(String direction) {
			        for (Path p : paths) {
			            if (p.getPathName().equalsIgnoreCase(direction))
			                return p;
			        }
			        return null;
			    }
			
			    public Item findItem(String itemName) {
			        for (Item i : items) {
			            if (i.getName().equalsIgnoreCase(itemName)) {
			                return i;
			            }
			        }
			        return null;
			    }
			
			    public String getName() {
			        return name;
			    }
			
			    public void addItem(Item item) {
			        items.add(item);
			    }
			
			    public void removeItem(Item item) {
			        items.remove(item);
			    }
			
			    public String getItemNames() {
			        String itemNames = "";
			        for (Item item : items) {
			            itemNames += item.getName() + "  ";
			        }
			        return itemNames;
			    }
			
			    public String getExits() {
			        String exits = "";
			        for (Path path : paths) {
			            exits += path.getPathName() + "  ";
			        }
			        return exits;
			    }
			
			    public String getNpcNames() {
			        String npcNames = "";
			        for (NPC npc : npcs) {
			            npcNames += npc.getName() + "  ";
			        }
			        return npcNames;
			    }
			
			    public void addNPC(NPC npc) {
			        npcs.add(npc);
			    }
			
			    public void addPlayer(Player player) {
			        players.add(player);
			    }
			
			    public void removePlayer(Player player) {
			        players.remove(player);
			    }
			
			    public void removeNPC(NPC npc) {
			        npcs.remove(npc);
			    }
			
			    public boolean hasPlayers(){
			        return players.size() > 0;
			    }
			
			    public Player getRandomPlayer() {
			        Random random = new Random();
			        int index = random.nextInt(players.size());
			        return players.get(index);
			    }
			}
			'''
		)
	}

	def static generateWeapon(IFileSystemAccess2 fsa) {
		fsa.generateFile(
			"gameDSL/Weapon.java",
			'''
			package gameDSL;
			
			public abstract class Weapon extends Item {
			
			    protected int damage;
			    protected int durability;
			
			    public Weapon(String name, int weight, int damage, int durability) {
			        super(name, weight);
			        this.damage = damage;
			        this.durability = durability;
			    }
			
			    public int getDamage() {
			        return damage;
			    }
			
			    public int getDurability() {
			        return durability;
			    }
			
			    public void reduceDurability(int i){
			        durability =- i;
			    }
			}
			'''
		)
	}

}
