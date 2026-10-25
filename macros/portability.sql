{#
  Les seules différences entre le Warehouse (T-SQL) et le Lakehouse (Spark SQL)
  sont regroupées ici. Les modèles, eux, sont identiques pour les deux moteurs.
#}


{#
  Texte -> entier.
  Le nullif n'est pas décoratif : cast('' as int) renvoie 0 en T-SQL,
  alors que Spark renvoie NULL. Sans lui, les deux moteurs ne donneraient
  pas le même résultat sur une valeur vide.
#}
{% macro to_int(column) -%}
    cast(nullif(trim({{ column }}), '') as {{ dbt.type_int() }})
{%- endmacro %}


{#
  Texte -> booléen.
  Rebrickable a écrit ses booléens en 't'/'f' puis en 'True'/'False' selon les époques.
  dbt.type_boolean() donne 'bit' sur le Warehouse et 'boolean' sur le Lakehouse.
#}
{% macro to_bool(column) -%}
    cast(case when lower(trim({{ column }})) in ('t', 'true', '1') then 1 else 0 end as {{ dbt.type_boolean() }})
{%- endmacro %}


{#
  Littéral "faux" pour filtrer une colonne booléenne.
  Ici, pas de macro cross-database toute faite : on utilise adapter.dispatch.
  T-SQL n'a pas de type booléen, on compare donc un bit à 0.
  Spark compare un boolean à false.
#}
{% macro sql_false() -%}
    {{ return(adapter.dispatch('sql_false', 'lego_fabric')()) }}
{%- endmacro %}

{% macro fabric__sql_false() -%}
    0
{%- endmacro %}

{% macro default__sql_false() -%}
    false
{%- endmacro %}
