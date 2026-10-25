-- Couleurs dominantes par thème racine (Star Wars, Technic, City...).
with theme_colors as (
    select
        s.root_theme_id,
        s.root_theme_name,
        sp.color_id,
        sum(sp.quantity) as total_quantity
    from {{ ref('int_set_parts') }} sp
    inner join {{ ref('mart_sets') }} s on sp.set_num = s.set_num
    group by s.root_theme_id, s.root_theme_name, sp.color_id
),

ranked as (
    select
        root_theme_id,
        root_theme_name,
        color_id,
        total_quantity,
        sum(total_quantity) over (partition by root_theme_id)                            as theme_total_quantity,
        dense_rank() over (partition by root_theme_id order by total_quantity desc)      as color_rank
    from theme_colors
)

select
    concat(r.root_theme_id, '-', r.color_id)                          as theme_color_key,
    r.root_theme_id,
    r.root_theme_name,
    r.color_id,
    c.color_name,
    c.rgb_hex,
    c.is_transparent,
    r.total_quantity,
    round(100.0 * r.total_quantity / r.theme_total_quantity, 2)       as pct_of_theme,
    r.color_rank
from ranked r
left join {{ ref('stg_colors') }} c on r.color_id = c.color_id
