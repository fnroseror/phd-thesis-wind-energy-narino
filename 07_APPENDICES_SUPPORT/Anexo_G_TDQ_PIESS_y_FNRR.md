\# Appendix G. Physical, mathematical, statistical-mechanical, and decision-oriented foundation of the TDQ-PIESS framework and the FNRR indicator



\## G.1. Purpose of this appendix



This appendix provides the formal scientific foundation of the hybrid interpretive framework associated with the doctoral thesis, with emphasis on four complementary levels:



1\. the physical description of the atmospheric system,

2\. the mathematical and predictive formulation of the problem,

3\. the statistical-mechanical interpretation of regional variability and structural disorder,

4\. the decision-oriented formalization inspired by the emerging TDQ perspective.



This appendix also defines the conceptual and mathematical basis of the FNRR indicator as a structural measure of regional non-regularity and as a bridge between free energy potential and usable energy interpretation.



\## G.2. Epistemological levels of the model



For scientific clarity, the framework is organized into differentiated epistemological levels.



\### Level 1. Physical level

At this level, the atmospheric system is described using observed meteorological variables and physically interpretable quantities such as air density, wind speed, and wind power density.



\### Level 2. Mathematical-predictive level

At this level, the problem is formulated as a forecasting and uncertainty-aware estimation task, including benchmark comparison, interval-based interpretation, and decision-relevant outputs.



\### Level 3. Statistical-mechanical level

At this level, the regional system is interpreted as an ensemble of possible configurations whose macroscopic behavior can be described through structured variability, uncertainty, and disorder-related quantities.



\### Level 4. Decision-oriented TDQ level

At this level, the framework incorporates a formal perspective in which states, prospects, coherence, and decision impact are treated as part of a broader decision-oriented interpretation inspired by TDQ.



\## G.3. Internal structure of this appendix



This appendix is organized as follows:



\- \*\*G.4. Physical description of the atmospheric system\*\*

\- \*\*G.5. Wind power density as the physical target variable\*\*

\- \*\*G.6. Predictive formulation and uncertainty-aware interpretation\*\*

\- \*\*G.7. Statistical-mechanical interpretation of regional variability\*\*

\- \*\*G.8. Formal definition of FNRR\*\*

\- \*\*G.9. Coherence, usable energy, and decision-oriented interpretation\*\*

\- \*\*G.10. TDQ-oriented extension of the framework\*\*

\- \*\*G.11. Scope, interpretation limits, and future projection\*\*

## G.4. Physical description of the atmospheric system



Let \\( z \\in \\{1,2,\\dots,Z\\} \\) denote the regional zone and let \\( t \\) denote time.

The observed atmospheric state of the system is defined as:



\\\[

\\mathbf{x}\_z(t)=

\\begin{bmatrix}

v\_z(t),\\; p\_z(t),\\; T\_z(t),\\; RH\_z(t),\\; PR\_z(t),\\; EV\_z(t),\\; NU\_z(t),\\; FA\_z(t), \\dots

\\end{bmatrix}^{\\top}

\\tag{G.1}

\\]



where:



\- \\( v\_z(t) \\): wind speed,

\- \\( p\_z(t) \\): atmospheric pressure,

\- \\( T\_z(t) \\): absolute temperature,

\- \\( RH\_z(t) \\): relative humidity,

\- \\( PR\_z(t) \\): precipitation,

\- \\( EV\_z(t) \\): evaporation,

\- \\( NU\_z(t) \\): cloudiness,

\- \\( FA\_z(t) \\): atmospheric phenomenon indicator.



This vector representation allows the regional atmospheric system to be treated as a structured physical state rather than as an isolated scalar time series.



\### G.4.1. Historical information of the system



The information available up to time \\( t \\) is denoted by:



\\\[

\\mathcal{H}\_{z,t}=\\{\\mathbf{x}\_z(\\tau): \\tau \\le t\\}

\\tag{G.2}

\\]



This notation is used to represent the historical state of the system and serves as the informational basis for forecasting and uncertainty-aware interpretation.



\### G.4.2. Air density from the ideal gas formulation



For dry air, the state equation can be written as:



\\\[

pV=nRT

\\tag{G.3}

\\]



Using \\( n = m/M \\), where \\( m \\) is mass and \\( M \\) is molar mass:



\\\[

pV=\\frac{m}{M}RT

\\tag{G.4}

\\]



Dividing by volume \\( V \\):



\\\[

p=\\frac{m}{V}\\frac{R}{M}T

\\tag{G.5}

\\]



Since density is defined as:



\\\[

\\rho=\\frac{m}{V}

\\tag{G.6}

\\]



it follows that:



\\\[

p=\\rho\\frac{R}{M}T

\\tag{G.7}

\\]



and therefore:



\\\[

\\rho=\\frac{Mp}{RT}

\\tag{G.8}

\\]



Equivalently, using the specific gas constant \\( R\_s=R/M \\):



\\\[

\\rho=\\frac{p}{R\_sT}

\\tag{G.9}

\\]



For dry air, this may be written as:



\\\[

\\rho\_d=\\frac{p}{R\_dT}

\\tag{G.10}

\\]



\### G.4.3. Moist-air correction through virtual temperature



When humidity effects are considered, air density may be approximated through virtual temperature:



\\\[

\\rho=\\frac{p}{R\_dT\_v}

\\tag{G.11}

\\]



with



\\\[

T\_v=T(1+0.608Q)

\\tag{G.12}

\\]



where \\( Q \\) is the specific humidity.



This distinction is important because the doctoral framework is physically grounded and aims to preserve consistency between meteorological state variables and energy-related interpretation.



\## G.5. Wind power density as the physical target variable



The kinetic energy of a moving air mass \\( m \\) with speed \\( v \\) is given by:



\\\[

E\_k=\\frac{1}{2}mv^2

\\tag{G.13}

\\]



If air with density \\( \\rho \\) crosses an area \\( A \\) at speed \\( v \\), the mass flow rate is:



\\\[

\\dot{m}=\\rho Av

\\tag{G.14}

\\]



Power is defined as energy per unit time:



\\\[

P=\\frac{dE\_k}{dt}

\\tag{G.15}

\\]



Substituting the mass flow rate into the kinetic-energy formulation:



\\\[

P=\\frac{1}{2}\\dot{m}v^2

\\tag{G.16}

\\]



and therefore:



\\\[

P=\\frac{1}{2}(\\rho Av)v^2

\\tag{G.17}

\\]



which leads to:



\\\[

P=\\frac{1}{2}\\rho Av^3

\\tag{G.18}

\\]



Dividing by area \\( A \\), the wind power density is obtained:



\\\[

WPD=\\frac{P}{A}=\\frac{1}{2}\\rho v^3

\\tag{G.19}

\\]



For zone \\( z \\) and time \\( t \\), the target variable of the doctoral framework is defined as:



\\\[

y\_z(t)=WPD\_z(t)=\\frac{1}{2}\\rho\_z(t)\\,v\_z^3(t)

\\tag{G.20}

\\]



\### G.5.1. Interpretation of WPD in the framework



This variable is adopted as the central physical target because it preserves the energetic meaning of the atmospheric resource.

Unlike wind speed alone, wind power density integrates both dynamic and thermodynamic information through the joint role of \\( v \\) and \\( \\rho \\).



\### G.5.2. Free energy over a forecast horizon



Let \\( H \\) denote the forecast horizon and \\( \\Delta t \\) the temporal resolution.

The free energy potential over the horizon is defined as:



\\\[

E^{\\text{free}}\_z(t,H)=\\sum\_{h=1}^{H}WPD\_z(t+h)\\,\\Delta t

\\tag{G.21}

\\]



In continuous form, this can be written as:



\\\[

E^{\\text{free}}\_z(t,H)=\\int\_t^{t+H}WPD\_z(\\tau)\\,d\\tau

\\tag{G.22}

\\]



This quantity represents the gross energetic potential before any structural penalty associated with non-regularity or decision-oriented correction is applied.



\## G.6. Predictive formulation and uncertainty-aware interpretation



The forecasting problem is formulated as a state-to-future mapping based on the historical information of the system.

For forecast horizon \\( h \\), let:



\\\[

\\widehat{y}\_{z,t+h|t}=\\mathcal{F}\_h(\\mathcal{H}\_{z,t};\\theta\_h)

\\tag{G.23}

\\]



where:



\- \\( \\widehat{y}\_{z,t+h|t} \\): forecast of the target variable at horizon \\( h \\),

\- \\( \\mathcal{F}\_h \\): predictive model associated with the horizon,

\- \\( \\mathcal{H}\_{z,t} \\): historical information available at time \\( t \\),

\- \\( \\theta\_h \\): model parameters.



The observed future value is represented as:



\\\[

y\_z(t+h)=\\mathcal{F}\_h(\\mathcal{H}\_{z,t};\\theta\_h)+\\varepsilon\_{z,t+h}

\\tag{G.24}

\\]



where \\( \\varepsilon\_{z,t+h} \\) is the forecast error.



\### G.6.1. Persistence benchmark



A minimum benchmark for comparison is the persistence forecast:



\\\[

\\widehat{y}^{\\text{pers}}\_{z,t+h|t}=y\_z(t)

\\tag{G.25}

\\]



This benchmark assumes that the future state remains equal to the current one and is used as a baseline to evaluate whether the predictive model adds real information beyond inertia.



\### G.6.2. Root mean squared error



For a set of \\( N \\) predictions at horizon \\( h \\), the root mean squared error of the model is:



\\\[

RMSE\_h^{(\\text{model})}

=

\\sqrt{

\\frac{1}{N}

\\sum\_{i=1}^{N}

\\left(y\_i-\\widehat{y}\_i\\right)^2

}

\\tag{G.26}

\\]



and for persistence:



\\\[

RMSE\_h^{(\\text{pers})}

=

\\sqrt{

\\frac{1}{N}

\\sum\_{i=1}^{N}

\\left(y\_i-\\widehat{y}^{\\text{pers}}\_i\\right)^2

}

\\tag{G.27}

\\]



\### G.6.3. Skill score with respect to persistence



The skill score is defined as:



\\\[

Skill\_h

=

1-\\frac{RMSE\_h^{(\\text{model})}}{RMSE\_h^{(\\text{pers})}}

\\tag{G.28}

\\]



A positive value indicates that the model improves on persistence, a value equal to zero indicates no improvement, and a negative value indicates degradation with respect to the benchmark.



\### G.6.4. Predictive distribution and PI90



Let the predictive distribution of the target variable be denoted by:



\\\[

Y\_{z,t+h}\\mid \\mathcal{H}\_{z,t}\\sim \\mathbb{P}\_{z,t,h}

\\tag{G.29}

\\]



The 90% prediction interval is defined as:



\\\[

PI90\_{z,t,h}

=

\\left\[

q\_{0.05}\\left(\\mathbb{P}\_{z,t,h}\\right),

q\_{0.95}\\left(\\mathbb{P}\_{z,t,h}\\right)

\\right]

\\tag{G.30}

\\]



and its width is:



\\\[

\\omega\_{z,t,h}

=

q\_{0.95}\\left(\\mathbb{P}\_{z,t,h}\\right)

\-

q\_{0.05}\\left(\\mathbb{P}\_{z,t,h}\\right)

\\tag{G.31}

\\]



\### G.6.5. Empirical interval coverage



The empirical coverage of the prediction interval is:



\\\[

\\widehat{Cov}\_{90}

=

\\frac{1}{N}

\\sum\_{i=1}^{N}

\\mathbf{1}\\{y\_i \\in PI90\_i\\}

\\tag{G.32}

\\]



A well-calibrated uncertainty-aware framework seeks:



\\\[

\\widehat{Cov}\_{90}\\approx 0.90

\\tag{G.33}

\\]



This uncertainty-aware interpretation is important because the doctoral framework is not restricted to point forecasting alone.

It explicitly treats forecast intervals as part of the scientific and decision-relevant interpretation of the system.



\## G.7. Statistical-mechanical interpretation of regional variability



The regional atmospheric system may be interpreted not only as a deterministic sequence of observations, but also as an ensemble of possible configurations compatible with a macroscopic regional regime.



Let:



\\\[

\\Omega\_z=\\{\\omega^{(z)}\_1,\\omega^{(z)}\_2,\\dots,\\omega^{(z)}\_{M\_z}\\}

\\tag{G.34}

\\]



denote the ensemble of admissible configurations associated with zone \\( z \\).



Each configuration \\( \\omega^{(z)}\_i \\) represents a possible structured atmospheric condition at the regional level and is associated with probability:



\\\[

P(\\omega^{(z)}\_i)=p^{(z)}\_i

\\tag{G.35}

\\]



subject to:



\\\[

p^{(z)}\_i \\ge 0,

\\qquad

\\sum\_{i=1}^{M\_z} p^{(z)}\_i = 1

\\tag{G.36}

\\]



\### G.7.1. Macroscopic observables



For any macroscopic observable \\( A \\), its ensemble expectation is defined as:



\\\[

\\langle A \\rangle\_z

=

\\sum\_{i=1}^{M\_z} p^{(z)}\_i\\,A(\\omega^{(z)}\_i)

\\tag{G.37}

\\]



This formulation is useful because the regional system is not interpreted as a single rigid atmospheric realization, but as a structured set of possible states whose aggregate behavior determines the observed macroscopic response.



\### G.7.2. Effective energetic interpretation of regional states



To give the ensemble a statistical-mechanical interpretation, each admissible configuration may be associated with an effective energy level:



\\\[

\\mathcal{E}^{(z)}\_i

\\tag{G.38}

\\]



This quantity does not necessarily represent microscopic molecular energy.

Instead, it is interpreted here as an effective energetic descriptor of the structured regional atmospheric configuration.



Under a Gibbs-type representation, the probability of each configuration may be written as:



\\\[

p^{(z)}\_i

=

\\frac{e^{-\\beta \\mathcal{E}^{(z)}\_i}}{Z\_z}

\\tag{G.39}

\\]



where \\( \\beta \\) is an inverse-scale parameter and:



\\\[

Z\_z

=

\\sum\_{i=1}^{M\_z} e^{-\\beta \\mathcal{E}^{(z)}\_i}

\\tag{G.40}

\\]



is the partition function associated with zone \\( z \\).



\### G.7.3. Entropy and structural disorder



The structural entropy of the ensemble is defined as:



\\\[

S\_z

=

\-\\sum\_{i=1}^{M\_z} p^{(z)}\_i \\ln p^{(z)}\_i

\\tag{G.41}

\\]



This entropy is interpreted as a measure of structural dispersion or disorder of the regional system.

A higher entropy indicates a broader spread of admissible configurations, which is consistent with higher structural variability.



\### G.7.4. Interpretation within the doctoral framework



In the context of the doctoral thesis, the statistical-mechanical level does not replace the physical or predictive formulation.

Instead, it provides a higher-order interpretation of the regional system as an ensemble with structured variability, uncertainty, and disorder.



This interpretation is relevant because the later introduction of FNRR is intended to quantify, in robust operational terms, a form of macroscopic non-regularity that is conceptually compatible with the existence of structural disorder in the system.



\## G.8. Formal definition of FNRR



The FNRR indicator is introduced as a structural measure of regional non-regularity.

Its purpose is to quantify, in an interpretable and robust way, the extent to which free energetic potential is affected by variability, abrupt transitions, and predictive uncertainty.



Let:



\\\[

w\_t = WPD\_z(t)

\\tag{G.42}

\\]



denote the wind power density series associated with zone \\( z \\).



\### G.8.1. Amplitude-related non-regularity



A first component is defined through the interquartile dispersion of the energetic series:



\\\[

A\_z

=

\\frac{IQR(w)}{\\operatorname{Med}(w)+\\varepsilon}

\\tag{G.43}

\\]



where:



\- \\( IQR(w)=Q\_{0.75}(w)-Q\_{0.25}(w) \\),

\- \\( \\operatorname{Med}(w)=Q\_{0.50}(w) \\),

\- \\( \\varepsilon>0 \\) is a small regularization constant.



This term measures how dispersed the energetic resource is with respect to its central level.



\### G.8.2. Transition-related non-regularity



A second component captures abrupt temporal changes:



\\\[

\\Delta w\_t = w\_t-w\_{t-1}

\\tag{G.44}

\\]



and



\\\[

G\_z

=

\\frac{\\operatorname{Med}(|\\Delta w|)}{\\operatorname{Med}(w)+\\varepsilon}

\\tag{G.45}

\\]



This term quantifies how strongly the system changes from one energetic state to the next.



\### G.8.3. Uncertainty-related non-regularity



A third component is based on the relative width of predictive uncertainty:



\\\[

U\_z

=

\\frac{\\operatorname{Med}(\\omega\_{z,t,h})}{\\operatorname{Med}(\\widehat{w}\_{z,t,h})+\\varepsilon}

\\tag{G.46}

\\]



where \\( \\omega\_{z,t,h} \\) is the PI90 width and \\( \\widehat{w}\_{z,t,h} \\) is the point forecast of wind power density.



This term captures how large the uncertainty envelope is relative to the expected energetic level.



\### G.8.4. Bounded transformation of the components



To guarantee boundedness and comparability, define:



\\\[

\\phi(x)=\\frac{x}{1+x},

\\qquad x\\ge 0

\\tag{G.47}

\\]



Then:



\\\[

a\_z=\\phi(A\_z)=\\frac{A\_z}{1+A\_z}

\\tag{G.48}

\\]



\\\[

g\_z=\\phi(G\_z)=\\frac{G\_z}{1+G\_z}

\\tag{G.49}

\\]



\\\[

u\_z=\\phi(U\_z)=\\frac{U\_z}{1+U\_z}

\\tag{G.50}

\\]



\### G.8.5. Convex definition of FNRR



The final indicator is defined as:



\\\[

FNRR\_z

=

\\alpha a\_z+\\beta g\_z+\\gamma u\_z

\\tag{G.51}

\\]



subject to:



\\\[

\\alpha,\\beta,\\gamma \\ge 0,

\\qquad

\\alpha+\\beta+\\gamma=1

\\tag{G.52}

\\]



This definition ensures that the indicator is interpretable as a weighted structural composition of amplitude dispersion, transition irregularity, and uncertainty-related non-regularity.



\### G.8.6. Mathematical properties of the indicator



Because \\( x\\ge 0 \\Rightarrow 0\\le x/(1+x)<1 \\), it follows that:



\\\[

0\\le a\_z,g\_z,u\_z<1

\\tag{G.53}

\\]



and therefore:



\\\[

0\\le FNRR\_z<1

\\tag{G.54}

\\]



since \\( FNRR\_z \\) is a convex combination of bounded nonnegative terms.



Furthermore, since:



\\\[

\\phi'(x)=\\frac{1}{(1+x)^2}>0

\\tag{G.55}

\\]



the indicator is monotonic with respect to each of its structural components.



\### G.8.7. Interpretive meaning



Within the doctoral framework, FNRR is interpreted as a macroscopic indicator of structural regional non-regularity.

It does not represent gross resource magnitude itself.

Instead, it measures the degree to which the energetic resource is structurally less coherent from the standpoint of stability, transition regularity, and predictive interpretability.



\## G.9. Coherence, usable energy, and decision-oriented interpretation



Once FNRR has been defined, the coherence of the regional energetic system is introduced as its complement:



\\\[

C\_z = 1 - FNRR\_z

\\tag{G.56}

\\]



Since \\( 0 \\le FNRR\_z < 1 \\), it follows that:



\\\[

0 < C\_z \\le 1

\\tag{G.57}

\\]



This quantity is interpreted as a structural coherence coefficient of the regional energetic system.



\### G.9.1. Usable energy



Let \\( E^{\\text{free}}\_z(t,H) \\) denote the free energy potential over forecast horizon \\( H \\).

The usable energy is defined as:



\\\[

E^{\\text{usable}}\_z(t,H)

=

C\_z\\,E^{\\text{free}}\_z(t,H)

\\tag{G.58}

\\]



or equivalently:



\\\[

E^{\\text{usable}}\_z(t,H)

=

\\bigl(1-FNRR\_z\\bigr)\\,E^{\\text{free}}\_z(t,H)

\\tag{G.59}

\\]



This definition introduces a physically interpretable distinction between gross energetic potential and structurally usable energy.



\### G.9.2. Meaning within the framework



Under this interpretation:



\- \\( E^{\\text{free}} \\) represents the gross energetic potential,

\- \\( FNRR \\) represents structural non-regularity,

\- \\( C\_z \\) represents structural coherence,

\- \\( E^{\\text{usable}} \\) represents the energetically relevant component after structural penalization.



This distinction is important because not all available energetic potential is equally suitable for stable interpretation, forecasting reliability, or decision-oriented use.



\### G.9.3. Decision-oriented significance



The distinction between free and usable energy is one of the central interpretive consequences of the framework.

It allows the energetic resource to be interpreted not only in terms of magnitude, but also in terms of coherence and structural quality.



This decision-oriented view prepares the transition from the physical-statistical core of the thesis toward a broader interpretive framework in which utility must be weighted by structural coherence and not only by gross intensity.



\## G.10. TDQ-oriented extension of the framework



The previous sections define the physical, predictive, and structural basis of the framework.

At this stage, a TDQ-oriented extension is introduced in order to provide a decision-based interpretation of states, prospects, coherence, and impact.



\### G.10.1. Prospect space



Let:



\\\[

\\Pi\_t=\\{\\pi\_1,\\pi\_2,\\dots,\\pi\_K\\}

\\tag{G.60}

\\]



denote the set of admissible prospects at time \\( t \\).

A prospect may represent, depending on the application context, a regional option, a forecast horizon, an operational strategy, or a decision alternative.



\### G.10.2. State of decision



A decision-oriented state may be represented in a formal prospect space as:



\\\[

|\\Psi\_t\\rangle

=

\\sum\_{k=1}^{K} c\_k(t)\\,|\\pi\_k\\rangle

\\tag{G.61}

\\]



subject to:



\\\[

\\sum\_{k=1}^{K}|c\_k(t)|^2=1

\\tag{G.62}

\\]



This representation does not imply that the atmospheric system is microscopic quantum matter in the strict physical sense.

Instead, it introduces a formal language in which multiple admissible prospects coexist before selection.



\### G.10.3. Mixed-state representation



When the decision context is not represented by a pure state alone, a mixed-state description may be introduced through a density operator:



\\\[

\\hat{\\rho}\_t

=

\\sum\_n p\_n\\,|\\psi\_n\\rangle\\langle \\psi\_n|

\\tag{G.63}

\\]



with:



\\\[

p\_n\\ge 0,

\\qquad

\\sum\_n p\_n=1

\\tag{G.64}

\\]



This representation is useful when the decision process is affected by uncertainty, incomplete information, or a mixture of admissible interpretive configurations.



\### G.10.4. Utility and coherence operators



Define a utility operator over the prospect basis:



\\\[

\\hat{U}

=

\\sum\_{k=1}^{K} U(\\pi\_k)\\,|\\pi\_k\\rangle\\langle \\pi\_k|

\\tag{G.65}

\\]



and a coherence operator:



\\\[

\\hat{C}

=

\\sum\_{k=1}^{K} C(\\pi\_k)\\,|\\pi\_k\\rangle\\langle \\pi\_k|

\\tag{G.66}

\\]



where \\( U(\\pi\_k) \\) denotes the utility assigned to prospect \\( \\pi\_k \\) and \\( C(\\pi\_k)=1-FNRR(\\pi\_k) \\) denotes its coherence.



A diagonal coherent utility operator may then be defined as:



\\\[

\\hat{J}

=

\\sum\_{k=1}^{K}

U(\\pi\_k)\\,C(\\pi\_k)\\,|\\pi\_k\\rangle\\langle \\pi\_k|

\\tag{G.67}

\\]



\### G.10.5. Expected coherent utility



Under the mixed-state representation, the expected coherent utility is:



\\\[

\\langle \\hat{J}\\rangle\_t

=

\\mathrm{Tr}(\\hat{\\rho}\_t \\hat{J})

\\tag{G.68}

\\]



This quantity gives a decision-oriented expectation in which utility is already weighted by structural coherence.



\### G.10.6. General decision functional



A broader decision functional may be written as:



\\\[

\\mathcal{J}\_t(\\pi\_k)

=

U\_t(\\pi\_k)\\,C\_t(\\pi\_k)-\\lambda\_x X\_t(\\pi\_k)

\\tag{G.69}

\\]



where:



\- \\( U\_t(\\pi\_k) \\): expected utility of the prospect,

\- \\( C\_t(\\pi\_k) \\): structural coherence of the prospect,

\- \\( X\_t(\\pi\_k) \\): external cost, operational risk, or adverse impact,

\- \\( \\lambda\_x \\): sensitivity coefficient associated with that external penalty.



The corresponding decision rule is:



\\\[

\\pi\_t^\\star

=

\\arg\\max\_{\\pi\_k\\in\\Pi\_t}\\mathcal{J}\_t(\\pi\_k)

\\tag{G.70}

\\]



\### G.10.7. Meaning of the TDQ-oriented extension



The TDQ-oriented extension of the framework is not introduced to replace the physical-statistical core of the doctoral thesis.

Its role is to provide a formal pathway for interpreting how states, uncertainty, coherence, and utility may become part of a broader decision-oriented scientific framework.



In this sense, the doctoral case functions as a physically grounded application domain from which a more general TDQ perspective may emerge in future work.



\## G.11. Scope, interpretation limits, and future projection



\### G.11.1. Scope of the framework



The framework developed in this appendix has four main scopes:



1\. to preserve the physical meaning of the atmospheric energy resource through wind power density,

2\. to integrate forecasting and uncertainty-aware interpretation into the scientific reading of the system,

3\. to define FNRR as a structural indicator of regional non-regularity,

4\. to open a formal pathway toward a broader decision-oriented interpretation through the emerging TDQ perspective.



\### G.11.2. Interpretation limits



This appendix does not claim that the atmospheric system is quantum in the microscopic physical sense.  

The quantum-inspired formalism introduced in the TDQ-oriented extension is used as a mathematical and interpretive framework for decision representation, not as a literal statement about microscopic atmospheric ontology.



Likewise, the statistical-mechanical interpretation does not imply that the regional system has been reduced to a closed canonical ensemble in a strict thermodynamic sense.  

Its role is interpretive and structural: to provide a higher-order language for understanding variability, admissible configurations, and macroscopic disorder.



\### G.11.3. Limits of FNRR



FNRR is introduced here as an original structural indicator.  

Its present formulation is intended to be:



\- interpretable,

\- bounded,

\- robust,

\- coherent with uncertainty-aware forecasting,

\- suitable for regional comparison.



However, its future refinement may include:

\- calibration studies,

\- sensitivity analysis for \\( \\alpha, \\beta, \\gamma \\),

\- comparison with alternative disorder or regularity indicators,

\- validation in other regions or domains.



\### G.11.4. Scientific value of the appendix



The scientific value of this appendix lies in the fact that it connects:

\- physical modeling,

\- predictive reasoning,

\- uncertainty interpretation,

\- structural non-regularity,

\- usable energy,

\- decision-oriented formalization.



This integrated view strengthens the conceptual backbone of the repository and preserves the theoretical identity of the doctoral work beyond the core thesis manuscript.



\### G.11.5. Future projection



The doctoral case presented in this repository may be interpreted as one grounded application domain for the broader development of TDQ.  

In future work, the same logic may be extended to other systems in which:



\- states evolve under uncertainty,

\- raw potential differs from usable potential,

\- coherence matters for interpretation,

\- decisions have internal and external consequences.



Under that perspective, the present appendix serves both as support for the doctoral thesis and as an initial formal seed for a more general decision-oriented scientific framework.

