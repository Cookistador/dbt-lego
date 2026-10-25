# LEGO × dbt dans Fabric : Warehouse vs Lakehouse

Un seul projet dbt, lancé sur deux moteurs : le Fabric Data Warehouse (adaptateur `dbt-fabric`, T-SQL) et le Lakehouse (adaptateur `dbt-fabricspark`, Spark SQL). Données : le catalogue Rebrickable.

## Contenu

```
notebooks/                      chargement bronze (notebook Fabric)
macros/portability.sql          les seules différences entre les deux moteurs
models/staging/      7 modèles  typage et renommage des tables bronze (tout arrive en texte)
models/intermediate/ 2 modèles  hiérarchie des thèmes, pièces par set (le modèle lourd)
models/marts/        4 modèles  sets, taille par année, couleurs par thème, top pièces
tests/                          test singulier sur la profondeur des thèmes
```

13 modèles et 41 tests de données, identiques pour les deux moteurs.

## Mise en place

1. **Dans un même workspace**, crée un Lakehouse `lh_lego` avec les schémas activés, et un Warehouse `wh_lego`.
2. **Bronze** : importe le notebook `notebooks/nb_load_rebrickable_bronze.ipynb`, attache `lh_lego` comme Lakehouse par défaut et lance-le une fois. Tu obtiens 12 tables dans `lh_lego.bronze`, toutes les colonnes en texte.
3. **dbt job Warehouse** : importe le projet, adaptateur *Fabric Data Warehouse*, connexion `wh_lego`, schéma `lego`, commande `build`. Le Warehouse lit le bronze via le SQL analytics endpoint du Lakehouse.
4. **dbt job Lakehouse** : même projet, adaptateur *Fabric Lakehouse*, Lakehouse `lh_lego`, schéma `lego`.
   - Le schéma doit être différent du nom du Lakehouse : c'est ce qui indique à l'adaptateur que les schémas sont activés.
   - Garde le même Lakehouse que le bronze. Les modèles s'écrivent dans `lh_lego.lego`, à côté de `lh_lego.bronze`.
5. Si tes noms diffèrent, change `bronze_lakehouse` et `bronze_schema` dans `dbt_project.yml`.

Mets le même nombre de threads des deux côtés (4 par exemple) pour que la comparaison tienne.

## Ce qui change entre les deux moteurs

C'est la matière de la séquence « ce qu'il a fallu adapter ».

| Où | Warehouse (T-SQL) | Lakehouse (Spark SQL) | Solution dans le projet |
|---|---|---|---|
| Filtrer un booléen | pas de type booléen, `bit = 0` | `= false` | macro `sql_false()` avec `adapter.dispatch` |
| Type booléen | `bit` | `boolean` | `dbt.type_boolean()` |
| `cast('' as int)` | renvoie `0` | renvoie `NULL` | `nullif(trim(...), '')` dans `to_int()` |
| `avg()` sur un entier | résultat entier tronqué | `double` | `avg(x * 1.0)` dans `mart_set_size_by_year` |
| `int / int` | entier | `double` | modulo dans `mart_sets` |

Les trois dernières lignes ne provoquent pas d'erreur : la requête passe sur les deux moteurs, mais pas avec le même résultat. Pour le montrer à l'écran, lance la version sans la correction des deux côtés.

Volontairement absents : CTE récursive (remplacée par trois auto-jointures), `TOP`/`LIMIT`, `ORDER BY` dans les modèles, packages dbt.

## Mesurer

- Lance `dbt build` deux ou trois fois de chaque côté.
- Côté Lakehouse, note séparément le premier run (démarrage de la session Spark) et les suivants. Sinon tu compares un démarrage de cluster à une requête.
- Relève la durée totale, la durée par modèle (surtout `int_set_parts`) et la consommation dans Capacity Metrics.
- Trois tests sont en `warn` exprès : pièces et couleurs d'inventaire absentes du catalogue, couleur sans nom dans `mart_colors_by_theme`. Ils signalent ces cas sans bloquer le build. Sur les vraies données, je ne sais pas encore s'ils remontent quelque chose.

## Ce qui a été vérifié

- Parsing du projet avec `dbt-fabric` 1.10.0 et `dbt-fabricspark` 1.12.2, les versions du runtime dbt job, sous dbt Core 1.11.
- Compilation en T-SQL et contrôle de syntaxe des 54 requêtes (modèles et tests).
- `dbt build` complet sur Spark 3.5 en local, sur un échantillon synthétique au format Rebrickable : 53 OK, 1 warn attendu, résultats contrôlés à la main.
- Chargement bronze du notebook rejoué en local (guillemets doublés, valeurs vides, tout en texte).

**Pas vérifié** : l'exécution réelle dans Fabric, sur le Warehouse comme sur le Lakehouse, et le téléchargement depuis Rebrickable dans le notebook.
