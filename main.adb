with ada.text_io,ada.integer_text_io,laby_functions,ada.command_line ;
use ada.text_io ;



procedure main is

        m : laby_functions.tree ;

        
        w : integer ;

        h : integer ;


        argu_count : integer := ada.command_line.argument_count ;

        procedure get_width_and_height(w,h : out integer) is
        begin
                put_line("Please enter maze width : ") ;
                ada.integer_text_io.get(w) ; 
                skip_line ;
                put_line("please enter maze height : ") ;
                ada.integer_text_io.get(h) ; 
                skip_line ;


        end get_width_and_height ;



begin



        if argu_count = 0 then

                get_width_and_height(w,h) ;

                m := new laby_functions.node ;

                m := laby_functions.maze_random(w,h) ;

                laby_functions.maze_svg(m,"maze.svg") ;

                laby_functions.solution_svg(m,"maze.svg") ;

        else

                for i in 1..argu_count loop

                        get_width_and_height(w,h) ;

                        m := laby_functions.maze_random(w,h) ;

                        laby_functions.maze_svg(m,ada.command_line.argument(i) & ".svg") ;

                        laby_functions.solution_svg(m,ada.command_line.argument(i) & ".svg") ;

                end loop ;

        end if ;






end main ;
