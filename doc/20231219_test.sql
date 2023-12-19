

SELECT
     dps.k, dps.v, d.date
FROM
     iro_datapoints as dps
     right JOIN dates d ON d.date = dps.d where d.date BETWEEN '2023-12-01' AND '2023-12-31'
ORDER BY
     d.date;

insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.1, '2023-12-16', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.2, '2023-12-17', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.3, '2023-12-18', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.4, '2023-12-19', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.5, '2023-12-20', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.6, '2023-12-21', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.7, '2023-12-22', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.8, '2023-12-23', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 1.9, '2023-12-24', '2023-12-12', '2023-12-12');
insert into iro_datapoints(k, v, d, created_at, updated_at) values ('a', 2.0, '2023-12-25', '2023-12-12', '2023-12-12');

select d.date from dates d where d.date BETWEEN '2023-12-01' AND '2023-12-31';
