package com.mk.autosecure.ui.view.multistatetogglebutton;

/**
 * Created by DoanVT on 2017/10/9.
 * Email: doanvt-hn@mk.com.vn
 */

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Parcelable;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatButton;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;
import java.util.ArrayList;
import java.util.List;

public class MultiStateToggleButton extends ToggleButton {

    private static final String TAG = MultiStateToggleButton.class.getSimpleName();

    private static final String KEY_BUTTON_STATES  = "button_states";
    private static final String KEY_INSTANCE_STATE = "instance_state";

    private int color0;
    private int color1;
    private int color2;
    private int color3;

    private ArrayList<Integer> selectedColorList = new ArrayList<>();

    /**
     * A list of rendered buttons. Used to get state, among others
     */
    List<View> buttons;

    /**
     * The specified texts
     */
    CharSequence[]   texts;

    /**
     * If true, multiple buttons can be pressed at the same time
     */
    boolean mMultipleChoice = false;

    private int currentValue = -1;

    /**
     * The layout containing all buttons
     */
    private LinearLayout mainLayout;

    private LinearLayout subLayout;

    public MultiStateToggleButton(Context context) {
        super(context, null);
    }

    public MultiStateToggleButton(Context context, AttributeSet attrs) {
        super(context, attrs);
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.MultiStateToggleButton, 0, 0);
        try {
            CharSequence[] texts = a.getTextArray(R.styleable.MultiStateToggleButton_values);
            color0 = a.getColor(R.styleable.MultiStateToggleButton_color0, 0);
            color1 = a.getColor(R.styleable.MultiStateToggleButton_color1, 0);
            color2 = a.getColor(R.styleable.MultiStateToggleButton_color2, 0);
            color3 = a.getColor(R.styleable.MultiStateToggleButton_color3, 0);
            selectedColorList.add(color0);
            selectedColorList.add(color1);
            selectedColorList.add(color2);
            selectedColorList.add(color3);
            colorPressed = a.getColor(R.styleable.MultiStateToggleButton_mstbPrimaryColor, 0);
            colorNotPressed = a.getColor(R.styleable.MultiStateToggleButton_mstbSecondaryColor, 0);
            colorPressedText = a.getColor(R.styleable.MultiStateToggleButton_mstbColorPressedText, 0);
            colorPressedBackground = a.getColor(R.styleable.MultiStateToggleButton_mstbColorPressedBackground, 0);
            pressedBackgroundResource = a.getResourceId(R.styleable.MultiStateToggleButton_mstbColorPressedBackgroundResource, 0);
            colorNotPressedText = a.getColor(R.styleable.MultiStateToggleButton_mstbColorNotPressedText, 0);
            colorNotPressedBackground = a.getColor(R.styleable.MultiStateToggleButton_mstbColorNotPressedBackground, 0);
            notPressedBackgroundResource = a.getResourceId(R.styleable.MultiStateToggleButton_mstbColorNotPressedBackgroundResource, 0);

            int length = 0;
            if (texts != null) {
                length = texts.length;
            }
            setElements(texts, null, new boolean[length]);
        } finally {
            a.recycle();
        }
    }

    /**
     * If multiple choice is enabled, the user can select multiple
     * values simultaneously.
     *
     * @param enable
     */
    public void enableMultipleChoice(boolean enable) {
        this.mMultipleChoice = enable;
    }

    @Override
    public Parcelable onSaveInstanceState() {
        Bundle bundle = new Bundle();
        bundle.putParcelable(KEY_INSTANCE_STATE, super.onSaveInstanceState());
        bundle.putBooleanArray(KEY_BUTTON_STATES, getStates());
        return bundle;
    }

    @Override
    public void onRestoreInstanceState(Parcelable state) {
        if (state instanceof Bundle) {
            Bundle bundle = (Bundle) state;
            setStates(bundle.getBooleanArray(KEY_BUTTON_STATES));
            state = bundle.getParcelable(KEY_INSTANCE_STATE);
        }
        super.onRestoreInstanceState(state);
    }

    /**
     * Set the enabled state of this MultiStateToggleButton, including all of its child buttons.
     *
     * @param enabled True if this view is enabled, false otherwise.
     */
    @Override
    public void setEnabled(boolean enabled) {
        for (int i = 0; i < getChildCount(); i++) {
            View child = getChildAt(i);
            child.setEnabled(enabled);
        }
    }

    /**
     * Set multiple buttons with the specified texts and default
     * initial values. Initial states are allowed, but both
     * arrays must be of the same size.
     *
     * @param texts            An array of CharSequences for the buttons
     * @param imageResourceIds an optional icon to show, either text, icon or both needs to be set.
     * @param selected         The default value for the buttons
     */
    public void setElements(@Nullable CharSequence[] texts, int[] imageResourceIds, boolean[] selected) {
        this.texts = texts;
        final int textCount = texts != null ? texts.length : 0;
        final int iconCount = imageResourceIds != null ? imageResourceIds.length : 0;
        final int elementCount = Math.max(textCount, iconCount);
        if (elementCount == 0) {
            return;
        }

        boolean enableDefaultSelection = true;
        if (selected == null || elementCount != selected.length) {
            enableDefaultSelection = false;
        }

        setOrientation(LinearLayout.HORIZONTAL);
        setGravity(Gravity.CENTER_VERTICAL);

        LayoutInflater inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        if (mainLayout == null) {
            mainLayout = (LinearLayout) inflater.inflate(R.layout.view_multi_state_toggle_button, this, true);
        }
        mainLayout.removeAllViews();

        if (subLayout == null) {
            subLayout = new LinearLayout(context);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
            layoutParams.gravity = Gravity.CENTER_VERTICAL;
            subLayout.setLayoutParams(layoutParams);
        }

        subLayout.removeAllViews();

        this.buttons = new ArrayList<>(elementCount);
        for (int i = 0; i < elementCount; i++) {
            Button b;
            if (i == 0) {
                // Add a special view when there's only one element
                if (elementCount == 1) {
                    b = (Button) inflater.inflate(R.layout.view_single_toggle_button, mainLayout, false);
                } else {
                    b = (Button) inflater.inflate(R.layout.view_left_toggle_button, mainLayout, false);
                }
            } else if (i == elementCount - 1) {
                b = (Button) inflater.inflate(R.layout.view_right_toggle_button, mainLayout, false);
            } else {
                b = (Button) inflater.inflate(R.layout.view_center_toggle_button, mainLayout, false);
            }
            b.setText(texts != null ? texts[i] : "");
            if (imageResourceIds != null && imageResourceIds[i] != 0) {
                b.setCompoundDrawablesWithIntrinsicBounds(imageResourceIds[i], 0, 0, 0);
            }
            final int position = i;
            b.setOnClickListener(new View.OnClickListener() {

                @Override
                public void onClick(View v) {
                    if (position != currentValue && listener != null) {
                        listener.onValueChanged(position);
                    }
                    setValue(position);
                }

            });
            b.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
            b.setMaxLines(1);
            mainLayout.addView(b);
            if (enableDefaultSelection) {
                setButtonState(b, selected[i]);
            }
            this.buttons.add(b);
        }
        mainLayout.addView(subLayout, 0);

        GradientDrawable gd = new GradientDrawable();
        gd.setCornerRadius(ViewUtils.dp2px(24));
        gd.setColor(context.getResources().getColor(R.color.gray));
        mainLayout.setBackground(gd);

    }

    /**
     * @return An array of the buttons' text
     */
    public CharSequence[] getTexts() {
        return this.texts;
    }

    /**
     * Set multiple buttons with the specified texts and default
     * initial values. Initial states are allowed, but both
     * arrays must be of the same size.
     *
     * @param buttons  the array of button views to use
     * @param selected The default value for the buttons
     */
    public void setButtons(View[] buttons, boolean[] selected) {
        final int elementCount = buttons.length;
        if (elementCount == 0) {
            return;
        }

        boolean enableDefaultSelection = true;
        if (selected == null || elementCount != selected.length) {
            com.orhanobut.logger.Logger.t(TAG).d("Invalid selection array");
            enableDefaultSelection = false;
        }

        setOrientation(LinearLayout.HORIZONTAL);
        setGravity(Gravity.CENTER_VERTICAL);

        LayoutInflater inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        if (mainLayout == null) {
            mainLayout = (LinearLayout) inflater.inflate(R.layout.view_multi_state_toggle_button, this, true);
        }
        mainLayout.removeAllViews();

        this.buttons = new ArrayList<>();
        for (int i = 0; i < elementCount; i++) {
            View b = buttons[i];
            final int position = i;
            b.setOnClickListener(new View.OnClickListener() {

                @Override
                public void onClick(View v) {
                    setValue(position);
                }

            });
            mainLayout.addView(b);
            if (enableDefaultSelection) {
                setButtonState(b, selected[i]);
            }
            this.buttons.add(b);
        }
        mainLayout.setBackgroundResource(R.drawable.button_section_shape);
    }

    public void setElements(CharSequence[] elements) {
        int size = elements == null ? 0 : elements.length;
        setElements(elements, null, new boolean[size]);
    }

    public void setElements(List<?> elements) {
        int size = elements == null ? 0 : elements.size();
        setElements(elements, new boolean[size]);
    }

    public void setElements(List<?> elements, Object selected) {
        int size = 0;
        int index = -1;
        if (elements != null) {
            size = elements.size();
            index = elements.indexOf(selected);
        }
        boolean[] selectedArray = new boolean[size];
        if (index != -1 && index < size) {
            selectedArray[index] = true;
        }
        setElements(elements, selectedArray);
    }

    public void setElements(List<?> texts, boolean[] selected) {
        if (texts == null) {
            texts = new ArrayList<>(0);
        }
        int size = texts.size();
        setElements(texts.toArray(new String[size]), null, selected);
    }

    public void setElements(int arrayResourceId, int selectedPosition) {
        // Get resources
        String[] elements = this.getResources().getStringArray(arrayResourceId);

        // Set selected boolean array
        int size = elements == null ? 0 : elements.length;
        boolean[] selected = new boolean[size];
        if (selectedPosition >= 0 && selectedPosition < size) {
            selected[selectedPosition] = true;
        }

        // Super
        setElements(elements, null, selected);
    }

    public void setElements(int arrayResourceId, boolean[] selected) {
        setElements(this.getResources().getStringArray(arrayResourceId), null, selected);
    }

    public void setButtonState(View button, boolean selected) {
        if (button == null) {
            return;
        }
        button.setSelected(selected);
        button.setBackgroundResource(selected ? R.drawable.button_pressed : R.drawable.button_not_pressed);
        if (colorPressed != 0 || colorNotPressed != 0) {
            button.setBackgroundColor(selected ? colorPressed : colorNotPressed);
        } else if (colorPressedBackground != 0 || colorNotPressedBackground != 0) {
            button.setBackgroundColor(selected ? colorPressedBackground : colorNotPressedBackground);
        }
        if (button instanceof Button) {
            int style = selected ? R.style.WhiteBoldText : R.style.PrimaryNormalText;
            ((AppCompatButton) button).setTextAppearance(this.getContext(), style);
            if (colorPressed != 0 || colorNotPressed != 0) {
                ((AppCompatButton) button).setTextColor(!selected ? colorPressed : colorNotPressed);
            }
            if (colorPressedText != 0 || colorNotPressedText != 0) {
                ((AppCompatButton) button).setTextColor(selected ? colorPressedText : colorNotPressedText);
            }
            if (pressedBackgroundResource != 0 || notPressedBackgroundResource != 0) {
                button.setBackgroundResource(selected ? pressedBackgroundResource : notPressedBackgroundResource);
            }
        }
    }

    public void setButtonState(View button, int relativePosition) {
        if (button == null) {
            return;
        }
        button.setSelected(relativePosition == 0);
        if (relativePosition == 0) {
            button.setBackgroundResource(R.drawable.button_pressed);
        } else if ( relativePosition > 0 ) {
            button.setBackgroundResource(R.drawable.button_not_pressed);
        } else {
            button.setBackgroundResource(R.drawable.button_not_pressed);
        }

        if (colorPressed != 0 || colorNotPressed != 0) {
            button.setBackgroundColor(relativePosition == 0 ? colorPressed : colorNotPressed);
        } else if (colorPressedBackground != 0 || colorNotPressedBackground != 0) {
            button.setBackgroundColor(relativePosition == 0 ? colorPressedBackground : colorNotPressedBackground);
        }
        if (button instanceof Button) {
            int style = relativePosition == 0 ? R.style.WhiteBoldText : R.style.PrimaryNormalText;
            ((AppCompatButton) button).setTextAppearance(this.getContext(), style);
            if (colorPressed != 0 || colorNotPressed != 0) {
                ((AppCompatButton) button).setTextColor(relativePosition != 0 ? colorPressed : colorNotPressed);
            }
            if (colorPressedText != 0 || colorNotPressedText != 0) {
                ((AppCompatButton) button).setTextColor(relativePosition == 0 ? colorPressedText : colorNotPressedText);
            }
            if (pressedBackgroundResource != 0 || notPressedBackgroundResource != 0) {
                button.setBackgroundResource(relativePosition == 0 ? pressedBackgroundResource : notPressedBackgroundResource);
            }
        }
    }

    public int getValue() {
        for (int i = 0; i < this.buttons.size(); i++) {
            if (buttons.get(i).isSelected()) {
                return i;
            }
        }
        return -1;
    }

    public void setValue(int position) {
        currentValue = position;
        subLayout.removeAllViews();
        mainLayout.removeAllViews();
        mainLayout.addView(subLayout);
        for (int i = 0; i < this.buttons.size(); i++) {
            if (i <= position) {
                View view = buttons.get(i);
                subLayout.addView(view);
            } else {
                View view = buttons.get(i);
                mainLayout.addView(view);
            }
        }

        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, subLayout.getChildCount());
        layoutParams.gravity = Gravity.CENTER_VERTICAL;
        subLayout.setLayoutParams(layoutParams);

        GradientDrawable gdSub = new GradientDrawable();
        gdSub.setCornerRadius(ViewUtils.dp2px(24));
        int size = subLayout.getChildCount();
        if (size > 0 && size <= selectedColorList.size()) {
            int color = selectedColorList.get(size - 1);
            if (size == 1) {
                gdSub.setColor(getResources().getColor(R.color.transparent));
            } else {
                gdSub.setColor(color);
            }
            subLayout.setBackground(gdSub);
//            com.orhanobut.logger.Logger.t(TAG).d("color = " + color);
        }

        for (int i = 0; i < this.buttons.size(); i++) {
            if (mMultipleChoice) {
                if (i == position) {
                    View b = buttons.get(i);
                    if (b != null) {
                        setButtonState(b, !b.isSelected());
                    }
                }
            } else {
                if (i == position) {
                    setButtonState(buttons.get(i), 0);
                    ((AppCompatButton)buttons.get(i)).setTextColor(selectedColorList.get(size - 1));
                } else {
                    setButtonState(buttons.get(i), i - position);
                    if (i < position && position <= 2) {
                        ((AppCompatButton)buttons.get(i)).setTextColor(getResources().getColor(R.color.white));
                    } else {
                        ((AppCompatButton)buttons.get(i)).setTextColor(getResources().getColor(R.color.colorPrimary));
                    }
                }
            }
        }
        super.setValue(position);
    }

    public boolean[] getStates() {
        int size = this.buttons == null ? 0 : this.buttons.size();
        boolean[] result = new boolean[size];
        for (int i = 0; i < size; i++) {
            result[i] = this.buttons.get(i).isSelected();
        }
        return result;
    }

    public void setStates(boolean[] selected) {
        if (this.buttons == null || selected == null ||
                this.buttons.size() != selected.length) {
            return;
        }
        int count = 0;
        for (View b : this.buttons) {
            setButtonState(b, selected[count]);
            count++;
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setColors(int colorPressed, int colorNotPressed) {
        super.setColors(colorPressed, colorNotPressed);
        refresh();
    }

    private void refresh() {
        boolean[] states = getStates();
        for (int i = 0; i < states.length; i++) {
            setButtonState(buttons.get(i), states[i]);
        }
    }
}