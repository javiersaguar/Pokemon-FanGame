// Fuentes de datos con versión FIJADA. Para actualizar: cambia la versión/commit
// (y el hash de integridad), regenera y revisa el diff de data/generated/.

export const SHOWDOWN = {
  package: 'pokemon-showdown',
  version: '0.11.11',
  tarball: 'https://registry.npmjs.org/pokemon-showdown/-/pokemon-showdown-0.11.11.tgz',
  integrity: 'sha512-FdW7gt3TkG4AdXmpMTPYX2kx42VEfY8tQApjW9wEHOGzwH6Kn97wD0o5uIzAc4xpO1W+Tim70Ti9+FNkMNCA2w==',
  files: ['pokedex', 'moves', 'abilities', 'items', 'learnsets', 'natures', 'typechart', 'formats-data'],
};

export const POKEAPI = {
  repo: 'PokeAPI/pokeapi',
  commit: 'a003ae375b69a99907ec273fe100d97e7f36321c',
  files: [
    'languages', 'versions', 'version_groups', 'stats', 'types', 'type_names',
    'pokemon_species', 'pokemon_species_names', 'pokemon_species_flavor_text',
    'pokemon', 'pokemon_stats', 'pokemon_forms', 'pokemon_form_names', 'pokemon_form_flavor_text',
    'growth_rates', 'experience',
    'moves', 'move_names', 'move_flavor_text',
    'abilities', 'ability_names', 'ability_flavor_text',
    'items', 'item_names', 'item_flavor_text', 'item_categories', 'item_pockets', 'item_flags', 'item_flag_map',
    'natures', 'nature_names',
  ],
};

// Español (España) en PokeAPI: languages.csv -> id 7, iso639 "es", iso3166 "es".
export const LANG_ES = 7;
export const LANG_EN = 9;
