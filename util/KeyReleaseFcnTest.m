function KeyReleaseFcnTest
      close all;
      h = figure;
      set(h,'WindowKeyReleaseFcn',@KeyPressFcn);
      function KeyPressFcn(~,evnt)
          fprintf('key event is: %s\n',evnt.Key);
      end
end