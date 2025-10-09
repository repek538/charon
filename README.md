# Charon - Space Rescue Gauntlet Game

> A blockchain-based space combat and rescue simulation game built on Starknet using the Dojo engine. Every ship is a unique NFT with distinct stats and history.

## 🎮 Game Overview

Charon is a player-vs-player space combat game where creators design dangerous rescue gauntlets and challengers attempt to complete them. Think of it as "create your own death run" in space - with real stakes and real NFT ownership.

### Core Concept

**Creators** stake tokens to design rescue missions by:
1. Placing a **rescue target NFT ship** at specific coordinates
2. Strategically positioning enemy NFT ships and stations across the grid

**Rescuers** pay an entry fee to attempt the mission with their own NFT ships. If rescuers reach the target ship and complete the rescue, they win the reward and potentially the target ship. If they fail, the creator keeps their fee. The better balanced your gauntlet (hard but fair), the more attempts you'll get!

## 🚀 Key Features

### 1. **NFT Ship Ownership**
- **Every ship is a unique NFT** with individual stats and combat history
- Ships can be traded, sold, or lost in failed rescues
- Battle-hardened ships gain reputation and value
- Rescue target ships become prizes for successful rescuers

### 2. **Rescue Gauntlet System**
- Creators place a **rescue target ship** at specific grid coordinates
- Strategic enemy ship and station placement around the target
- Credit-based tier system determines available ships and difficulty
- Dynamic threat budget allocation based on stakes
- Mortality level requirements for winning

### 3. **Realistic Space Combat**
- 8 distinct ship classes (Pirate Skiff to Battleship)
- 5 factions with unique bonuses (UN, Mars Federation, Kuiper Union, Pirates, Independent)
- Realistic armament: Railguns, Torpedoes, and PDCs (Point Defense Cannons)
- Fuel, reactor power, and ammo management
- Each ship tracks damage, fuel consumption, and battle stats

### 4. **Economic Model**
- Stake-based gauntlet creation
- Entry fees for rescue attempts
- Success rate tracking and reputation system
- Creator earnings from failed attempts
- NFT ship trading marketplace
- Rescue target ships as grand prizes

### 5. **Station Types**
Strategic station placement for advanced gauntlet design:
- **Military Base** - Heavy defenses (Threat: 80)
- **Shipyard** - Repair and resupply (Threat: 50)
- **Research Lab** - Tech advantages (Threat: 40)
- **Smuggler Den** - Hidden threats (Threat: 35)
- **Mining Outpost** - Resource control (Threat: 30)
- **Trade Hub** - Economic centers (Threat: 25)
- **Relay Station** - Communications (Threat: 20)
- **Habitat** - Civilian centers (Threat: 15)

## 📊 Ship Classes

| Class | Speed | Role | Threat Cost | PDC Ammo | Torpedoes |
|-------|-------|------|-------------|----------|-----------|
| **Pirate Skiff** | 120 | Fast raider | 5 | 5,000 | 6 |
| **Corvette** | 100 | Patrol/Scout | 10 | 15,000 | 16 |
| **Freighter** | 40 | Cargo hauler | 12 | 12,000 | 0 |
| **Frigate** | 80 | Multi-role warship | 20 | 30,000 | 24 |
| **Destroyer** | 70 | Fleet backbone | 35 | 50,000 | 48 |
| **Cruiser** | 60 | Heavy firepower | 50 | 80,000 | 72 |
| **Carrier** | 50 | Drone/fighter platform | 60 | 150,000 | 60 |
| **Battleship** | 40 | Capital ship | 100 | 200,000 | 120 |

*Each ship is a unique NFT with individual ContractAddress as ID*

## 🎯 Faction Bonuses

- **UN**: +20% shields, +10% crew
- **Mars Federation**: +15% speed, +20% fuel capacity
- **Kuiper Union**: +20% hull, +30% cargo
- **Pirates**: +25% speed, +20% ammo (including +30% PDC rounds), -20% shields, -30% crew
- **Independent**: +10% cargo, +10% fuel

## 💰 Credit Tier System

| Tier | Credits | Threat Budget | Max Battleships | Max Military Bases |
|------|---------|---------------|-----------------|-------------------|
| **1 - Beginner** | 0-99 | ~50-100 | 0 | 0 |
| **2 - Intermediate** | 100-499 | ~100-300 | 0 | 0 |
| **3 - Advanced** | 500-999 | ~300-500 | 1 | 0 |
| **4 - Expert** | 1,000-4,999 | ~500-750 | 2 | 1 |
| **5 - Legendary** | 5,000+ | 750+ | 4 | 2 |

## 🎲 How to Play

### As a Creator:

**1. Select Your Rescue Target Ship**
- Choose an NFT ship from your collection to be rescued
- Place it at strategic coordinates on the grid
- This ship becomes the prize if rescuers succeed

**2. Stake Your Tokens**
- Decide on creator stake, rescue reward, and attempt fee
- Set credits required and mortality level
- Risk losing your rescue target ship!

**3. Design Your Gauntlet**
- System generates recommended enemy ship/station composition
- Place enemy NFT ships from your fleet or spawn new ones
- Customize placement strategically around rescue target
- Balance difficulty to maximize attempts

**4. Earn From Attempts**
- Collect entry fees from failed rescue attempts
- Pay out rewards on successful rescues (and potentially lose target ship)
- Build reputation with fair but challenging gauntlets
- Damaged enemy ships can be repaired and reused

### As a Rescuer:

**1. Choose Your Ship & Mission**
- Select an NFT ship from your fleet
- Browse available gauntlets by tier and difficulty
- Check success rates, creator reputation, and **rescue target ship value**
- Pay entry fee to attempt

**2. Navigate the Gauntlet**
- Pilot your NFT rescue ship through enemy formations
- Manage fuel, ammo, and shields
- Reach the rescue target coordinates
- Extract the target ship to win

**3. Claim Your Reward**
- **Win**: Collect rescue reward + creator's stake + **rescue target ship NFT**
- **Lose**: Creator keeps your entry fee (your ship survives but may be damaged)
- **Your ship gains battle history** regardless of outcome

## 🏆 NFT Ship Mechanics

### Ship Identity
Each ship is a unique NFT with:
- Unique ContractAddress as identifier
- Current owner tracking
- Associated gauntlet/mission history
- Faction allegiance
- Ship class designation
- Individual stats, ammo, fuel levels
- Battle damage and repair history

### Ship Value Factors
- **Base class rarity** (Battleships > Corvettes)
- **Faction bonuses applied**
- **Battle history and victories**
- **Current condition** (hull, shields, ammo)
- **Upgrades and modifications** (future feature)

### Rescue Target Ship
- Placed by creator at specific (x, y) coordinates
- Acts as the "finish line" for rescuers
- Becomes prize if rescue succeeds
- Can be any ship class (affects gauntlet value)
- Creator risks losing valuable ship for higher rewards

### Ship Trading
- Open marketplace for buying/selling NFT ships
- Battle-proven ships command premium prices
- Rare faction/class combinations highly valued
- Damaged ships sold at discount (require repairs)

## 🔧 Technical Architecture

### Project Structure

**Models Layer**
- Game state management
- Rescue gauntlet configuration with target ship location
- Ship NFT entities with unique ContractAddress identifiers
- Ship and station composition tracking
- Mini-zone spatial indexing

**Systems Layer**
- Rescue gauntlet creation and management
- Ship spawning and lifecycle management
- Rescue attempt logic (in development)
- Combat resolution system (planned)

**Utils Layer**
- Credit helper: Tier calculations and composition generation
- Armament helper: Ship stat initialization with faction modifiers

### Key Components

**Ship NFT Model**
Every ship is a unique NFT containing:
- Unique identifier (ContractAddress)
- Owner address
- Gauntlet association
- Faction and class
- Combat statistics (hull, shields, speed, crew)
- Armament (railguns, torpedoes, PDCs)
- Resources (fuel, reactor power, ammunition)
- Spatial coordinates

**Rescue Gauntlet Model**
Gauntlet configurations include:
- Rescue target ship NFT identifier
- Target location coordinates
- Creator information and stakes
- Reward pool and entry fees
- Difficulty settings (credits, mortality level)
- Threat budget allocation
- Attempt tracking and success rates

**Ship Composition**
Tracks enemy ship placement:
- Ship count by class
- Individual ship NFT identifiers
- Spatial distribution
- Threat cost calculations

**Station Composition**
Tracks defensive station placement:
- Station count by type
- Strategic positioning
- Combined threat values

## 📐 Game Balance

### Threat Budget Formula
Base Budget: 50 points plus bonus calculated as (Credits / 10) × 5 points

**Example**: 750 credits yields 50 + (750/10 × 5) = 425 threat points

### Rescue Target Value Impact
- **Higher value target ships** attract more rescuers
- **Rare ship classes** justify higher entry fees
- **Creator risk vs reward** balancing target value with stakes

### Economic Equilibrium
Optimal success rate targets 20-40% for maximum profitability:
- Enough failures for creator to profit from entry fees
- Enough successes to maintain rescuer interest
- Total creator risk includes both stake and target ship value

### NFT Ship Lifecycle
Ships progress through: Mint → Gauntlet Placement → Combat → Survival/Damage → Repair → Trading/Reuse (or Loss/Destruction)

## 🎨 Frontend Features (Planned)

- NFT ship gallery and inventory management
- Ship stats and battle history viewer
- Grid-based gauntlet editor with drag-drop ship placement
- Real-time rescue attempt visualization
- NFT marketplace integration
- Ship condition and damage indicators
- Rescue target placement tool
- Wallet integration (ArgentX, Braavos)

## 🗺️ Roadmap

### Phase 1: Core Mechanics ✅
- [x] Ship NFT models with faction bonuses
- [x] Credit tier system
- [x] Gauntlet creation system
- [x] Armament helper module
- [x] Rescue target placement

### Phase 2: Combat System (In Progress)
- [ ] Ship movement and navigation
- [ ] Weapon firing mechanics
- [ ] Collision detection
- [ ] Rescue extraction mechanics
- [ ] Win/loss conditions with NFT transfer

### Phase 3: NFT Integration
- [ ] ERC-721 compliance for ships
- [ ] NFT metadata (stats, history, images)
- [ ] Ship trading marketplace
- [ ] Battle history tracking
- [ ] Ship repair and maintenance system

### Phase 4: Economic Layer
- [ ] Token integration (staking, rewards)
- [ ] Staking mechanisms
- [ ] Reward distribution with NFT prizes
- [ ] Reputation system
- [ ] Ship valuation algorithms

### Phase 5: Advanced Features
- [ ] Team rescue attempts (multi-ship coordination)
- [ ] Dynamic difficulty adjustment
- [ ] Seasonal gauntlet contests
- [ ] Legendary ship blueprints (rare NFTs)
- [ ] Ship customization and upgrades
- [ ] Ship breeding/fusion mechanics

## 🏅 NFT Ship Rarity Tiers

### Common (60%)
- Pirate Skiff, Freighter
- Standard faction bonuses
- Basic loadouts

### Uncommon (25%)
- Corvette, Frigate
- Standard bonuses
- Good combat potential

### Rare (10%)
- Destroyer, Cruiser
- Enhanced faction bonuses (+5%)
- Superior armament

### Epic (4%)
- Carrier, Battleship
- Significant faction bonuses (+10%)
- Maximum firepower

### Legendary (1%)
- Unique named ships
- Extreme faction bonuses (+20%)
- Special abilities (future)
- Historical significance

## 🎯 Design Philosophy

> "Every ship tells a story. Every rescue is a gamble. The best gauntlets aren't impossible - they're *almost* survivable. That sweet spot between challenge and fairness is where fortunes are made, and legends are born."

Charon rewards strategic thinking over grinding. Creators must balance difficulty to attract attempts while protecting their valuable rescue target ships. Rescuers must master ship management, risk assessment, and decide which of their NFT ships to risk on each mission. The blockchain ensures transparency, true ownership, and fair play.

**Your ships are yours. Your victories are permanent. Your losses matter.**

## 🛠️ Development Setup

### Prerequisites
- Rust & Cargo
- Scarb (Cairo package manager)
- Dojo CLI
- Starknet Foundry

### Installation Steps
1. Clone the repository
2. Build contracts with Scarb
3. Run tests
4. Deploy to local Katana devnet
5. Migrate contracts

### Development Guidelines
- Follow Cairo naming conventions
- Add comprehensive tests for new features
- Update documentation
- Optimize gas costs
- Respect NFT standards and best practices

## 🤝 Contributing

We welcome contributions! Please see our Contributing Guide for details on:
- Code style and conventions
- Testing requirements
- Pull request process
- Community guidelines

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

