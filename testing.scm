`((lambda
     ($clo)
            ((closure-code $clo)
             $clo
             ,@(map cc Es))) ,(cc E0))


(let (($clo ,(cc E0)))
            ((closure-code $clo)
             $clo
             ,@(map cc Es)))