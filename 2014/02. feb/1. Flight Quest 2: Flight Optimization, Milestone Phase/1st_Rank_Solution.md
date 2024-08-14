# Winning approach by id

Team Members - id118392

REF: https://www.kaggle.com/competitions/flight2-milestone/discussion/6015

## Summary

The flight model and the cost function of the Flight Simulator were simplified. Optimal altitude and airspeed for current aircraft weight were computed for cruise, ascent, and descent. An automatic agent was constructed which minimizes the cost function selecting one of three actions for each time moment.

## Modeling Techniques

The flight cost consists of fuel cost and delay cost. The latter consists of a linear term (crew and other hourly costs) and a nonlinear term (passenger dissatisfaction costs). The nonlinear term is small relative to the linear one and was neglected. The cost equation was:

flight*cost = fuel_consumed * fuel*cost + flight_duration * delay_cost

Please note that this equation does not include the actual delay of arrival. Hence, all parameters influencing this delay were neglected. In particular, both ground and traffic conditions at a destination airport were not taken into account.

This solution uses several simplifications:

- Only crew and other hourly costs are taken into account. Passenger dissatisfaction costs are neglected.
- Ground conditions and traffic conditions at a destination airport are ignored. The arrival model is disabled in the Flight Simulator.
- Wind direction and magnitude are assumed to be constant and correspond to the cutoff time.
- Airplane goes in a straight line to a destination. Only altitude and airspeed are changing.

The second principal optimization concerns flight dynamics. Each time moment an aircraft has one of the three states: cruise, ascend, or descent. Each of the states has its own fuel expense depending on aircraft weight, airspeed and altitude. Optimal parameters for each state were found minimizing the cost function. Cruise state is usually optimal at maximal altitude and some specific airspeed. Descent fuel expense does not depend on airspeed. Descending with maximal airspeed is obviously the most efficient state. Ascent is always the least efficient.

The automatic agent minimizes the cost function selecting one of the three actions for each time moment:

- change altitude and cruise straight for 50 miles;
- 2000 feet ascent and subsequent descent;
- descend to a destination (10000 feet on an airport border).

At present the optimal flight plans do not look to be natural. In reality a cycle of ascent with subsequent descent can not be more efficient than cruise at constant altitude. Hopefully, the next version of the Flight Simulator will be more realistic.
