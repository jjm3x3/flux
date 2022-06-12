require "./gui_elements/button.rb"

describe "Button" do
    describe "intialize" do
        it "should construct" do
            # setup
            window_double = double("window")
            font_double = double("font")

            # execute
            Button.new(window_double, font_double, "HI", 1,1,1)

            # assert
            # nothing much to assert just making sure this works
        end
    end

    describe "draw" do
        it "should draw" do
            # setup
            window_double = double("window")
            font_double = double("font", draw_text: nil)
            sut = Button.new(window_double, font_double, "HI", 1,1,1, {is_pressed: ->() {} })

            # execute
            sut.draw

            # assert
            # nothing much to assert just making sure this works
        end
    end
end

