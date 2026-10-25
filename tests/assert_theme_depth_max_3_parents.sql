-- int_themes_flattened remonte au plus trois niveaux de parents.
-- Si Rebrickable ajoute un quatrième niveau, ce test échoue au lieu de produire un mauvais thème racine.
select t.theme_id
from {{ ref('stg_themes') }} t
inner join {{ ref('stg_themes') }} p1 on t.parent_theme_id = p1.theme_id
inner join {{ ref('stg_themes') }} p2 on p1.parent_theme_id = p2.theme_id
inner join {{ ref('stg_themes') }} p3 on p2.parent_theme_id = p3.theme_id
where p3.parent_theme_id is not null
