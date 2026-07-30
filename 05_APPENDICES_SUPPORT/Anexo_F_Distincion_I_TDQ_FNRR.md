# ANEXO F — Distinción entre `I_TDQ` y FNRR

## 1. `I_TDQ`

`I_TDQ` es un índice interno de estado del pipeline horario TDQ–PIESS/KFAS. Resume condiciones internas de confianza, variabilidad efectiva y memoria del estado.

- escala: horaria;
- función: predictor o variable auxiliar interna;
- no modula energía;
- no sustituye el diagnóstico residual;
- no equivale al FNRR.

En archivos históricos puede aparecer con una etiqueta anterior `FNRR`. Esa etiqueta se conserva por integridad del objeto congelado, pero su interpretación correcta es `I_TDQ`.

## 2. FNRR

El Factor de No Regularidad Regional es un descriptor de la etapa trimestral separada.

Para cada zona `z` y trimestre `q`:

- `Q0.50,zq`: mediana de WPD;
- `Q*0.90,zq = max(Q0.90,zq, Q0.50,zq)`;
- `W0 = 1 W/m²`;
- `ε = 10^-12`.

La implementación canónica es:

```text
FNRR_zq =
clip_[0,1](
  [ln(1 + Q*0.90,zq / W0) - ln(1 + Q0.50,zq / W0)] /
  [ln(1 + Q*0.90,zq / W0) + ε]
)
```

El FNRR anual se obtiene mediante media ponderada por las horas teóricas de los trimestres.

## 3. Propiedades y límites

- `0 ≤ FNRR ≤ 1`;
- es adimensional porque el argumento del logaritmo se normaliza por `W0`;
- no es estrictamente invariante a cambios de escala;
- la comparación exige la misma unidad y el mismo `W0`;
- resume separación relativa entre el nivel central y la cola superior;
- no es una ley física universal.

## 4. Modulación energética

```text
E_usable = (1 - FNRR) E_free
```

`E_free` es un indicador anualizado de energía integrada por unidad de área.  
`E_usable` es un indicador estructuralmente modulado.

Ninguno representa generación eléctrica real, energía libre termodinámica o energía técnicamente garantizada.
