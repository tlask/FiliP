within PNlib.PN.Blocks;
block enablingOutDisBeneGreedy "enabling process of output transitions"
  parameter input Integer nOut "number of output transitions";
  input Integer arcWeight[:] "arc weights of output transitions";
  input Integer t "current token number";
  input Integer minTokens "minimum capacity";
  input Boolean TAout[:] "active output transitions with passed time";
  input Real enablingBene[:] "enabling benefit of output transitions";
  input Boolean timePassed "Does any timePassed of a output transition";
  output Boolean TEout_[nOut] "enabled output transitions";
protected
  Boolean TEout[nOut] "enabled output transitions";
  Integer arcWeightSum "arc weight sum";
  Integer Index "benefit Index";
  Real enablingBene_[nOut] "Benefit";
  Real BestValue "Max Benefit";
algorithm
  TEout := fill(false, nOut);
  arcWeightSum := 0;
  when timePassed then
      arcWeightSum := PNlib.Functions.OddsAndEnds.conditionalSumInt(arcWeight, TAout);  //arc weight sum of all active output transitions
      if t - arcWeightSum >= minTokens then  //Place has no actual conflict; all active output transitions are enabled
        TEout := TAout;
        Index:=0;
        BestValue:=0;
        enablingBene_:=enablingBene;
      else
        arcWeightSum := 0;
        enablingBene_:=enablingBene;
        for i in 1: nOut loop
          BestValue:=max(enablingBene_);
          Index:=Modelica.Math.Vectors.find(BestValue,enablingBene_);
          if Index>0 and TAout[Index] and t-(arcWeightSum+arcWeight[Index]) >= minTokens then
            TEout[Index] := true;
            arcWeightSum := arcWeightSum + arcWeight[Index];
          end if;
          enablingBene_[Index]:=-1;
        end for;
      end if;
  end when;
  // hack for Dymola 2017
  // TEout_ := TEout and TAout;
  for i in 1:nOut loop
    TEout_[i] := TEout[i] and TAout[i];
  end for;
end enablingOutDisBeneGreedy;
