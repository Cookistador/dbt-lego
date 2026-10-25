-- Aplatit la hiérarchie des thèmes sans CTE récursive :
-- trois auto-jointures suffisent, et le même SQL tourne sur les deux moteurs.
-- Le test assert_theme_depth_max_3_parents vérifie que la profondeur ne dépasse pas.
with themes as (
    select * from {{ ref('stg_themes') }}
)

select
    t.theme_id,
    t.theme_name,
    t.parent_theme_id,
    p1.theme_name as parent_theme_name,
    coalesce(p3.theme_id, p2.theme_id, p1.theme_id, t.theme_id)         as root_theme_id,
    coalesce(p3.theme_name, p2.theme_name, p1.theme_name, t.theme_name) as root_theme_name,
    case
        when p3.theme_id is not null then 3
        when p2.theme_id is not null then 2
        when p1.theme_id is not null then 1
        else 0
    end as theme_depth
from themes t
left join themes p1 on t.parent_theme_id = p1.theme_id
left join themes p2 on p1.parent_theme_id = p2.theme_id
left join themes p3 on p2.parent_theme_id = p3.theme_id
