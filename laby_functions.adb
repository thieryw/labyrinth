with ada.text_io,ada.integer_text_io,ada.float_text_io,ada.unchecked_deallocation,ada.numerics.discrete_random,ada.containers.doubly_linked_lists ;
use ada.text_io ;


package body laby_functions is

        
        function maze_random(W,H : integer) return Tree is

                procedure create_children(leaf : in out node) is
                        procedure update_node_and_children(leaf : in out node) is


                                procedure random_wall_and_door(leaf : in out node) is  

                                        subtype intervall_wall is integer range 1..(if leaf.wall = vertical then leaf.width else leaf.height) - 1 ;
                                        package Randomizer_wall is new ada.numerics.discrete_random(intervall_wall) ;

                                        subtype intervall_door is integer range 0..(if leaf.wall = vertical then leaf.height else leaf.width) - 1 ;
                                        package Randomizer_door is new ada.numerics.discrete_random(intervall_door) ;

                                        hasard_wall : Randomizer_wall.generator ;
                                        hasard_door : Randomizer_door.generator ;

                                begin
                                        Randomizer_wall.reset(hasard_wall) ;
                                        Randomizer_door.reset(hasard_door) ;

                                        leaf.wall_offset := Randomizer_wall.random(hasard_wall) ;
                                        leaf.door_offset := Randomizer_door.random(hasard_door) ;

                                end random_wall_and_door ;





                        begin

                                leaf.left_child := new node ;
                                leaf.right_child := new node ;

                                leaf.left_child.all.x := leaf.x ;
                                leaf.left_child.all.y := leaf.y ;

                                random_wall_and_door(leaf) ;

                                if leaf.wall = vertical then


                                        leaf.right_child.all.x := leaf.wall_offset + leaf.x ;
                                        leaf.right_child.all.y := leaf.y ;
                                        leaf.left_child.all.width := leaf.wall_offset ;
                                        leaf.left_child.all.height := leaf.height ;
                                        leaf.right_child.all.width := leaf.width - leaf.wall_offset ;
                                        leaf.right_child.all.height := leaf.height ;

                                else

                                        leaf.right_child.all.x := leaf.x ;
                                        leaf.right_child.all.y := leaf.wall_offset + leaf.y ;
                                        leaf.left_child.all.width := leaf.width ;
                                        leaf.left_child.all.height := leaf.wall_offset ;
                                        leaf.right_child.all.width := leaf.width ;
                                        leaf.right_child.all.height := leaf.height - leaf.wall_offset ;

                                end if ;





                        end update_node_and_children ;

                        function choose_betwine_horizontal_and_vertical return wall_type is
                                subtype intervall is integer range 0..1 ;
                                package Randomizer is new ada.numerics.discrete_random(intervall) ;
                                hasard : Randomizer.generator ;
                                choice : integer ;
                                orientation : wall_type ;
                        begin
                                Randomizer.reset(hasard) ;
                                choice := Randomizer.random(hasard) ;

                                if choice = 0 then
                                        orientation := vertical ;
                                else
                                        orientation := horizontal ;
                                end if ;

                                return orientation ;

                        end choose_betwine_horizontal_and_vertical ;


                begin

                        if leaf.width /= 1 and leaf.height /= 1 then

                                if leaf.width > leaf.height then

                                        leaf.wall := vertical ;
                                        update_node_and_children(leaf) ;

                                elsif leaf.width < leaf.height then

                                        leaf.wall := horizontal ;
                                        update_node_and_children(leaf) ;

                                else
                                        leaf.wall := choose_betwine_horizontal_and_vertical ;
                                        update_node_and_children(leaf) ; 

                                end if ;

                        else

                                leaf.wall := no_wall ;

                        end if ;


                        if leaf.wall = NO_WALL then

                                return ;

                        end if ;


                        create_children(leaf.left_child.all);
                        create_children(leaf.right_child.all);

                end create_children ;

                root :  tree ;

        begin

                root := new Node;

                root.all.x := 0 ;
                root.all.y := 0 ;
                root.all.width := W ;
                root.all.height := H ;

                create_children(root.all);


                return root;


        end maze_random ;

        procedure show_tree_content(maze : tree ; index : integer) is
        begin

                put_line(integer'image(index) & "wall ; x ; y ; width ; height ; wall_offset ; door_offset") ;
                put_line(wall_type'image(maze.all.wall) & " ; " & 
                integer'image(maze.all.x) & " ; " & 
                integer'image(maze.all.y) & " ; " &
                integer'image(maze.all.width) & " ; " &
                integer'image(maze.all.height) & " ; " & 
                integer'image(maze.all.wall_offset) & " ; " & 
                integer'image(maze.all.door_offset)) ;

                new_line ;

                if maze.all.wall = no_wall then
                        return ;
                end if ;

                show_tree_content(maze.all.left_child,index+1) ;
                show_tree_content(maze.all.right_child,index + 1) ;

        end show_tree_content ;

        procedure maze_svg(maze : tree ; file_name : string) is 

                function Build_line( x1,x2 : integer ; y1,y2 : integer ; color : string := "rgb(0,0,0)") return string is
                begin

                        return "<line" & 
                        " x1=" & '"' & integer'image(x1) & '"' & 
                        " y1=" & '"' & integer'image(y1) & '"' & 
                        " x2=" & '"' & integer'image(x2) & '"' & 
                        " y2=" & '"' & integer'image(y2) & '"' & 
                        " style=" & '"' & "stroke:" & color & ";stroke-width:0.2" & '"' & "/>" & ASCII.LF;

                end Build_line ;



                procedure write_tree_to_svg(maze : tree ; f : file_type) is 
                        type string_access is access string ;
                        p_line : string_access ;
                        procedure free is new ada.unchecked_deallocation(string,string_access) ;
                begin


                        if maze.all.wall = vertical then

                                p_line := new string'(
                                        Build_line(maze.all.x + maze.all.wall_offset,
                                        maze.all.x + maze.all.wall_offset,
                                        maze.all.y,
                                        maze.all.door_offset + maze.all.y)  
                                        & 
                                        Build_line(maze.all.x + maze.all.wall_offset,
                                        maze.all.x + maze.all.wall_offset,
                                        maze.all.y + maze.all.door_offset + 1,
                                        maze.all.height + maze.all.y)
                                        ) ;

                        elsif maze.all.wall = horizontal then

                                p_line := new string'(
                                        Build_line( maze.all.x,
                                        maze.all.door_offset + maze.all.x,
                                        maze.all.y + maze.all.wall_offset,
                                        maze.all.y + maze.all.wall_offset)
                                        & 
                                        Build_line(maze.all.x + maze.all.door_offset + 1,
                                        maze.all.width + maze.all.x,
                                        maze.all.y + maze.all.wall_offset,
                                        maze.all.y + maze.all.wall_offset)
                                        ) ;

                        else 
                                return;


                        end if;


                        put(f,p_line.all) ;

                        free(p_line) ;


                        write_tree_to_svg(maze.all.left_child,f) ;
                        write_tree_to_svg(maze.all.right_child,f) ;

                end write_tree_to_svg ;

                f : file_type ;

        begin
                create(f,name => file_name) ;



                put(f,"<svg width=" & '"' & ' ' & 
                integer'image(maze.all.width) & '"' & ' ' & "height=" & '"' & ' ' & 
                integer'image(maze.all.height) & '"' & '>' & ASCII.LF & 
                Build_line(1,maze.all.width,0,0) & 
                Build_line(0,0,0,maze.all.height) & 
                Build_line(0,maze.all.width - 1,maze.all.height,maze.all.height) & 
                Build_line(maze.all.width,maze.all.width,0,maze.all.height)) ;


                write_tree_to_svg(maze,f) ;

                close(f) ;


        end maze_svg ;

        procedure solution_svg(m : tree ; file_name : string) is

               -- package node_list is new ada.containers.doubly_linked_lists(node) ;
               -- package point_list is new ada.containers.doubly_linked_lists(point) ;


               -- procedure solve(root : node ; solution : out point_list.list) is





               --         function find_room_with_entrance(root : node) return node is

               --         begin
               --                 if root.wall = no_wall then
               --                         return root ;
               --                 else
               --                         return find_room_with_entrance(root.left_child.all) ;
               --                 end if ;

               --         end find_room_with_entrance ;



               --         procedure get_rooms_and_doors(root : node ; rooms : out node_list.list ; doors : out point_list.list)  is



               --                 function get_door(node_value : node) return point is

               --                         door : point ;


               --                 begin


               --                         if node_value.wall = vertical then

               --                                 door.x := float(node_value.x + node_value.wall_offset) ;
               --                                 door.y := float(node_value.y + node_value.door_offset) + 0.5 ;

               --                         else

               --                                 door.x := float(node_value.x + node_value.door_offset) + 0.5 ;
               --                                 door.y := float(node_value.y + node_value.wall_offset) ;


               --                         end if ;

               --                         return door ;


               --                 end get_door ;


               --         begin

               --                 if root.wall = no_wall then

               --                         node_list.append(rooms,root) ;
               --                 else

               --                         point_list.append(doors,get_door(root)) ;
               --                         get_rooms_and_doors(root.left_child.all,rooms,doors) ;
               --                         get_rooms_and_doors(root.right_child.all,rooms,doors) ;

               --                 end if ;



               --         end get_rooms_and_doors ;



               --         function is_door_on_room(room : node ; door : point) return boolean is


               --         begin
               --                 return ((door.x > float(room.x) and door.x < float(room.x + room.width)) and 
               --                         (door.y = float(room.y) or door.y = float(room.y + room.height)))

               --                         or

               --                                 ((door.y > float(room.y) and door.y < float(room.y + room.height)) and 
               --                                         (door.x = float(room.x) or door.x = float(room.x + room.width))) ;


               --         end is_door_on_room ;




               --         procedure find_connected_rooms(room : node ; rooms : node_list.list ; doors : point_list.list ; connected_rooms : in out node_list.list) is

               --                 function are_two_rooms_connected(room_1,room_2 : node ; doors: point_list.list) return boolean is



               --                         is_true : boolean ;

               --                 begin

               --                         is_true := false ;
               --                         for c of doors loop

               --                                 if (room_1.x /= room_2.x or room_1.y /= room_2.y) 
               --                                         and (is_door_on_room(room_1,c) 
               --                                         and is_door_on_room(room_2,c)) then

               --                                         is_true := true ;

               --                                 end if ;

               --                         end loop ;

               --                         return is_true ;




               --                 end are_two_rooms_connected ;


               --                 c : node_list.cursor := node_list.first(rooms) ; 


               --         begin
               --                 for c of rooms loop

               --                         if are_two_rooms_connected(room,c,doors) then

               --                                 node_list.append(connected_rooms,c) ;
               --                         end if ;
               --                 end loop ;

               --         end find_connected_rooms ;

               --         procedure solve_from(room : node ; previous_room : node ; rooms : node_list.list ; doors : point_list.list ; exit_door : point ; rooms_leading_to_exit : in out node_list.list) is
               --                 function is_on_exit(exit_door : point ; room : node) return boolean is
               --                 begin
               --                         return (float(room.x) < exit_door.x and float(room.x + room.width) > exit_door.x) and exit_door.y = float(room.y + room.height) ;

               --                 end is_on_exit ;

               --                 connected_rooms : node_list.list ;
               --                 is_dead_end : boolean := true ;


               --         begin

               --                 find_connected_rooms(room,rooms,doors,connected_rooms) ;


               --                 for c of connected_rooms loop

               --                         if c.x /= previous_room.x or c.y /= previous_room.y then
               --                                 is_dead_end := false ;
               --                                 solve_from(c,room,rooms,doors,exit_door,rooms_leading_to_exit) ;
               --                                 if not node_list.is_empty(rooms_leading_to_exit) then
               --                                         node_list.prepend(rooms_leading_to_exit,room) ;
               --                                         return ;
               --                                 end if ;

               --                         end if ;


               --                 end loop ;

               --                 if is_dead_end then

               --                         if is_on_exit(exit_door,room) then
               --                                 node_list.prepend(rooms_leading_to_exit,room) ;
               --                         end if ;

               --                 else

               --                         if is_on_exit(exit_door,room) then
               --                                 node_list.prepend(rooms_leading_to_exit,room) ;
               --                         end if ;
               --                 end if ;

               --         end solve_from ;


               --         entrance_door : constant point := (x => float(root.x) + 0.5, y => float(root.y)) ;
               --         exit_door : constant point := (x => float(root.width) - 0.5, y => float(root.height)) ;
               --         rooms : node_list.list ;
               --         doors : point_list.list ;
               --         entrance : node ;
               --         previous_room : node ;
               --         rooms_leading_to_exit : node_list.list ;
               --         c : node_list.cursor ;
               --         c_next : node_list.cursor ;


               -- begin

               --         entrance := find_room_with_entrance(root) ;
               --         previous_room := entrance ;
               --         get_rooms_and_doors(root,rooms,doors) ;

               --         

               --         put("sexe") ;

               --         solve_from(entrance,previous_room,rooms,doors,exit_door,rooms_leading_to_exit) ;

               --         c := node_list.first(rooms_leading_to_exit) ;
               --         c_next := node_list.first(rooms_leading_to_exit) ;

               --         for i in 1..integer(node_list.length(rooms_leading_to_exit)) - 1 loop
               --                 node_list.next(c_next) ;
               --                 for d of doors loop
               --                         if is_door_on_room(node_list.element(c),d) and is_door_on_room(node_list.element(c_next),d) then
               --                                 point_list.append(solution,d) ;
               --                         end if ;
               --                 end loop ;

               --                 node_list.next(c) ;

               --         end loop ;

               --         point_list.prepend(solution,entrance_door) ;
               --         point_list.append(solution,exit_door) ;





               -- end solve ;

                package point_list is new ada.containers.doubly_linked_lists(point) ;
                procedure solve(maze : node ; doors_to_exit : out point_list.list) is


                        function is_on_rectangle(rectangle : node ; door : point) return boolean is
                        begin

                                return ((door.x > float(rectangle.x) and door.x < float(rectangle.x + rectangle.width)) and 
                                        (door.y = float(rectangle.y) or door.y = float(rectangle.y + rectangle.height)))

                                        or

                                                ((door.y > float(rectangle.y) and door.y < float(rectangle.y + rectangle.height)) and 
                                                        (door.x = float(rectangle.x) or door.x = float(rectangle.x + rectangle.width))) ;


                        end is_on_rectangle ;

                        function get_door(node_value : node) return point is

                                door : point ;

                        begin

                                if node_value.wall = vertical then

                                        door.x := float(node_value.x + node_value.wall_offset) ;
                                        door.y := float(node_value.y + node_value.door_offset) + 0.5 ;

                                else

                                        door.x := float(node_value.x + node_value.door_offset) + 0.5 ;
                                        door.y := float(node_value.y + node_value.wall_offset) ;

                                end if ;

                                return door ;

                        end get_door ;
                        --

                        procedure solve_betwin(n : node ; entrance_door,exit_door : point ; doors_from_entrance_to_exit : out point_list.list) is
                                


                                door_on_wall : point ;
                                door_list_right : point_list.list ;
                                door_list_left : point_list.list ;
                                

                        begin

                                if n.wall = no_wall then
                                        point_list.append(doors_from_entrance_to_exit,exit_door) ;
                                else
                                        if is_on_rectangle(n.left_child.all,entrance_door) and is_on_rectangle(n.right_child.all,exit_door) then
                                                door_on_wall := get_door(n) ;
                                                solve_betwin(n.left_child.all,entrance_door,door_on_wall,door_list_left) ;
                                                solve_betwin(n.right_child.all,door_on_wall,exit_door,door_list_right) ;

                                        elsif is_on_rectangle(n.left_child.all,exit_door) and is_on_rectangle(n.right_child.all,entrance_door) then
                                                door_on_wall := get_door(n) ;
                                                solve_betwin(n.right_child.all,entrance_door,door_on_wall,door_list_left) ;
                                                solve_betwin(n.left_child.all,door_on_wall,exit_door,door_list_right) ;

                                        end if ;

                                        for c of door_list_left loop
                                                point_list.append(doors_from_entrance_to_exit,c) ;
                                        end loop ;

                                        for c of door_list_right loop
                                                point_list.append(doors_from_entrance_to_exit,c) ;
                                        end loop ;

                                        if is_on_rectangle(n.left_child.all,entrance_door)  then
                                                solve_betwin(n.left_child.all,entrance_door,exit_door,doors_from_entrance_to_exit) ;
                                        else
                                                solve_betwin(n.right_child.all,entrance_door,exit_door,doors_from_entrance_to_exit) ;
                                        end if ;

                                end if ;





                        end solve_betwin ;

                        entrance_door : point := (x => float(maze.x) + 0.5 , y => float(maze.y)) ;
                        exit_door : point := (x => float(maze.x + maze.width) - 0.5 , y => float(maze.y + maze.height)) ;

                begin

                        solve_betwin(maze,entrance_door,exit_door,doors_to_exit) ;

                        point_list.prepend(doors_to_exit,entrance_door) ;

                end solve ;

                function Build_line( x1,x2 : float ; y1,y2 : float ; color : string := "rgb(100,0,0)") return string is
                begin

                        return "<line" & 
                        " x1=" & '"' & float'image(x1) & '"' & 
                        " y1=" & '"' & float'image(y1) & '"' & 
                        " x2=" & '"' & float'image(x2) & '"' & 
                        " y2=" & '"' & float'image(y2) & '"' & 
                        " style=" & '"' & "stroke:" & color & ";stroke-width:0.2" & '"' & "/>" & ASCII.LF;

                end Build_line ;


                solution : point_list.list ;
                c : point_list.cursor ;
                c_next : point_list.cursor ;
                f : file_type ;



        begin


                solve(m.all,solution) ;

                
                c := point_list.first(solution) ;
                c_next := point_list.first(solution) ;
                open(f,append_file,file_name) ;

                for i in 1..integer(point_list.length(solution)) - 1 loop
                        point_list.next(c_next) ;

                        put(f,Build_line(point_list.element(c).x,point_list.element(c_next).x,point_list.element(c).y,point_list.element(c_next).y)) ;

                        point_list.next(c) ;

                end loop ;



                close(f) ;



        end solution_svg ;





end laby_functions ;
