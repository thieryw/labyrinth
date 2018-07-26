package laby_functions is     




        type point is 

                record

                        x,y : float ;

                end record ;

        type node is private ;

        type tree is access node ;




        function maze_random(W,H : integer) return Tree ;
        procedure maze_svg(maze : tree ; file_name : string) ;
        procedure show_tree_content(maze : tree ; index : integer) ;
        procedure solution_svg(m : tree ; file_name : string) ;

        private 

        type wall_type is (vertical,horizontal,no_wall) ;

        type node is
                record
                        wall : wall_type ;
                        left_child : tree ;
                        right_child : tree ;
                        x,y : natural ;
                        width,height : natural ;
                        wall_offset : natural ;
                        door_offset : natural ;
                end record ;


end laby_functions ;
