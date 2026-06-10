function cost = tunning(kk)
assignin('base','kk',kk);
sim('PSO_tunning_PID.slx');
cost= ITAE(length(ITAE));
end
