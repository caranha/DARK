# Knowledge Model

Each agent has Knowledge represented as a list of tiles, and the information they have about that tile.

This knowledge is used when the agent makes decisions.

## Information:

Each agent has the following information about a tile:

- Timestamp: When they acquired this knowledge
- Tile: The tile itself
- Water: If the tile has water

## Forgetting

- Agents forget information that they know about a tile if it is older than a certain amount.
- Agents forget information that they know about a tile if they know too much. Older information is forgotten first.

## Communication

Agents can exchange information with other agents in the same nest.

TODO: Information Exchange Model -- probably an action.