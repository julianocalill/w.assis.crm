create or replace function public.crm_dashboard_snapshot(
    p_funil_id integer,
    p_user_id uuid default null
)
returns jsonb
language sql
stable
as $$
with base as (
    select
        id,
        contato_id,
        vigencia,
        retorno,
        ativo,
        origem,
        seguradora,
        tipo_seguro,
        coalesce(premio_liquido, 0) as premio_liquido,
        coalesce(comissao_percentual, 0) as comissao_percentual,
        coalesce(agenciamento_percentual, 0) as agenciamento_percentual,
        indicador,
        corretor_id,
        funil_id,
        etapa_nome,
        coalesce(status, 'aberto') as status,
        coalesce(excluido, false) as excluido,
        data_fechamento,
        criado_em,
        motivo_perda,
        ramo_seguro,
        responsavel_id,
        is_checked,
        motivo_perda_id,
        nome_oportunidade,
        bubble_id,
        origem_id,
        seguradora_id,
        ramo_id,
        coalesce(valor_receita, 0) as valor_receita
    from public.oportunidades
    where funil_id = p_funil_id
      and coalesce(excluido, false) = false
      and (p_user_id is null or corretor_id = p_user_id)
),
kpis as (
    select
        count(*)::bigint as total_oportunidades,
        coalesce(sum(premio_liquido), 0)::numeric as premio_total,
        coalesce(sum(premio_liquido * ((comissao_percentual + agenciamento_percentual) / 100)), 0)::numeric as receita_estimada,
        coalesce(avg(premio_liquido), 0)::numeric as ticket_medio,
        coalesce(avg(case when premio_liquido > 0 then (comissao_percentual + agenciamento_percentual) end), 0)::numeric as comissao_media
    from base
),
etapas as (
    select
        e.nome,
        e.ordem,
        count(b.id)::bigint as total
    from public.etapas_funil e
    left join base b
      on b.etapa_nome = e.nome
     and b.status = 'aberto'
    where e.funil_id = p_funil_id
    group by e.nome, e.ordem
),
ramos as (
    select
        coalesce(nullif(trim(ramo_seguro), ''), 'Sem ramo') as nome,
        count(*)::bigint as total
    from base
    group by coalesce(nullif(trim(ramo_seguro), ''), 'Sem ramo')
    order by total desc, nome asc
    limit 12
),
recentes as (
    select
        id,
        contato_id,
        vigencia,
        retorno,
        ativo,
        origem,
        seguradora,
        tipo_seguro,
        premio_liquido,
        comissao_percentual,
        agenciamento_percentual,
        indicador,
        corretor_id,
        funil_id,
        etapa_nome,
        status,
        excluido,
        data_fechamento,
        criado_em,
        motivo_perda,
        ramo_seguro,
        responsavel_id,
        is_checked,
        motivo_perda_id,
        nome_oportunidade,
        bubble_id,
        origem_id,
        seguradora_id,
        ramo_id,
        valor_receita
    from base
    where status = 'ganho'
    order by coalesce(data_fechamento, criado_em::date) desc, criado_em desc
    limit 5
)
select jsonb_build_object(
    'kpis', coalesce((select to_jsonb(kpis) from kpis), '{}'::jsonb),
    'etapas', coalesce((select jsonb_agg(jsonb_build_object('nome', nome, 'total', total) order by ordem) from etapas), '[]'::jsonb),
    'ramos', coalesce((select jsonb_agg(jsonb_build_object('nome', nome, 'total', total)) from ramos), '[]'::jsonb),
    'recentes', coalesce((select jsonb_agg(to_jsonb(recentes)) from recentes), '[]'::jsonb)
);
$$;
