# Protocolo de preservación de resultados del Capítulo 3

## Decisión central

Los valores numéricos y objetos gráficos de la versión aprobada se conservan sin modificación.
La auditoría complementaria no se utiliza para sustituir silenciosamente esos resultados, sino para delimitar su alcance y documentar su robustez.

## Redacción metodológica recomendada

> Las métricas presentadas corresponden al pipeline predictivo aprobado y se reproducen exactamente a partir de sus archivos finales de predicción. La auditoría posterior identificó diferencias entre el protocolo declarado y la implementación histórica, especialmente en el uso del periodo de prueba, el alineamiento de persistencia y el soporte físico de las predicciones. Por esta razón, los resultados se conservan como evidencia del pipeline aprobado, mientras una evaluación complementaria, ejecutada con separación cronológica estricta, se reporta como análisis de robustez y no como sustitución retroactiva.

## Redacción de resultados recomendada

> En el pipeline aprobado, el Skill-RMSE fue positivo en las doce combinaciones zona-horizonte y la cobertura PI90 calibrada fue cercana al 90 %. Estos valores describen el comportamiento de dicha implementación y no deben interpretarse, por sí solos, como demostración de superioridad universal ni como validación independiente de toda la arquitectura.

## Límite obligatorio

No se afirmará que la auditoría corrigió el pipeline manteniendo exactamente los mismos resultados. La igualdad numérica pertenece al pipeline histórico; la corrección metodológica constituye un análisis separado.

