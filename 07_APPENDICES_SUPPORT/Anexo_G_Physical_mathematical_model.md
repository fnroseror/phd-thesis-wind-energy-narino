\# Physical and Mathematical Formulation of the Model



\## 1. System Definition



The wind system is modeled as a complex dynamical system whose evolution over time can be represented through a general state:



|\\psi(t)\\rangle



where |\\psi(t)\\rangle describes the physical state of the atmospheric system, including the interaction of meteorological variables such as wind speed, temperature, pressure, humidity, and boundary conditions.



The temporal evolution of the system is governed by a dynamic operator:

where \\hat{\\Lambda} represents the system evolution operator.



\---



\## 2. Definition of the Evolution Operator



The operator \\hat{\\Lambda} is defined as a function of the fundamental components of the system:



\\hat{\\Lambda} = f(E, O, S, FNRR)



where:



\- E: System energy, associated with atmospheric flow dynamics  

\- O: Structural order, representing patterns, correlations, and regularities  

\- S: Physical system, defined by meteorological variables and external conditions  

\- FNRR: Factor of Regional Non-Regularity, representing structural deviation  



\---



\## 3. State Evolution



The evolution of the system is defined as:



|\\psi(t)\\rangle = \\hat{\\Lambda}(E,O,S,FNRR) |\\psi\_0\\rangle



This formulation allows interpreting wind behavior as a trajectory in a state space, where each state represents a physical configuration of the system.



\---



\## 4. Formal Definition of FNRR



The Factor of Regional Non-Regularity (FNRR) is defined as a dimensionless quantity that measures the deviation of the system from an ideal structured behavior.



Let X(t) be a representative variable of the system (e.g., wind speed or wind power density).



FNRR is defined as:



FNRR = 1 - (E\_struct / E\_total)



where:



\- E\_total: total energy of the system  

\- E\_struct: energy associated with the structured component  



This definition implies:



\- FNRR → 0: highly structured system (high predictability)  

\- FNRR → 1: highly irregular system (low predictability)  



\---



\## 4.1 Spectral Interpretation



From a spectral perspective, the signal X(t) can be decomposed into:



X(t) = X\_struct(t) + X\_noise(t)



where:



\- X\_struct(t): structured component (low entropy)  

\- X\_noise(t): stochastic component (high entropy)  



Thus:



\- E\_struct corresponds to the energy of X\_struct(t)  

\- E\_total corresponds to the total signal energy  



FNRR therefore quantifies the proportion of non-structured energy within the system.



\---



\## 4.2 Relation to Entropy



FNRR can be interpreted as an indirect measure of system entropy:



FNRR ∝ S



where S denotes entropy.



Thus:



\- Higher FNRR → higher entropy → higher uncertainty  

\- Lower FNRR → higher order → greater predictability  



\---



\## 5. Usable Energy Definition



The usable energy of the system is defined as:



E\_usable = (1 - FNRR) E\_free



where:



\- E\_free: total available energy  

\- E\_usable: effectively exploitable energy  



This formulation introduces structural complexity as a modulating factor of energy usability.



\---



\## 6. Model Interpretation



The proposed model redefines wind prediction as a physical state evolution problem rather than a purely statistical task.



Within this framework:



\- Data correspond to measurements of system states  

\- The model describes system evolution  

\- FNRR quantifies structural complexity  

\- Prediction corresponds to state projection in time  



This approach enables the integration of physics, statistics, and data science into a unified modeling framework.

