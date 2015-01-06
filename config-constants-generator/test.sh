#!/bin/sh


function createWorkingConfig
{
    t=$1
    echo "[Test Group 1]" > $t
    echo "test_name | test.name.prop | string | a second name test" >> $t
    echo "int_name | int.name.property | int  | An integer value" >> $t
    echo "[Test Group! 2]" >> $t
    echo "double_name | dbl.name.property | double | A double value" >> $t
    echo "array_name | ary.name.property | array | An array value" >> $t
}

function test_java_working
{
    config=$1
    testdir=`mktemp -d -t test`
    python ezconfiguration_constants_generator.py -g "java" -c $config -o "${testdir}/EzBakePropertyConstants.java"

    javac "${testdir}/EzBakePropertyConstants.java"

    if [ $? -ne 0 ]; then
        echo "Generating a correct config did not work correctly."
    fi

    rm -rf ${testdir}
}

function test_python_working
{
    config=$1
    testdir=`mktemp -d -t test`
    python ezconfiguration_constants_generator.py -g "py" -c $config -o "${testdir}/EzBakePropertyConstants.py"
    pyProg="from EzBakePropertyConstants import EzBakePropertyConstants\nworked=False\nif not EzBakePropertyConstants.TEST_NAME == 'test.name.prop':\n\tprint 'There was an error in the python code'\ntry:\n\tEzBakePropertyConstants.TEST_NAME = 'new name'\nexcept Exception as e:\n\tworked=True\nif not worked:\n\tprint 'There was an error in python, const was changed'"
    cd $testdir
    echo $pyProg > $testdir/test.py
    echo $pyProg | python
    cd - > /dev/null
    rm -rf $testdir
}

function test_java_bad
{
    echo $2 > $1
    python ezconfiguration_constants_generator.py -g "java" -c $1 -o /dev/null -f > /dev/null
    if [ $? -eq 0 ]; then
        echo "Bad config passed: " + $2
    fi
}

function test_java_not_working
{
    testfile=`mktemp -t test`
    test_java_bad $testfile "bad name | bad.name.property | string | a bad name"
    test_java_bad $testfile "bad_prop | bad name.property | string | a bad prop"
    test_java_bad $testfile "bad_type | bad.type.property | sstring | a bad string"
    test_java_bad $testfile "123 | bad.numerical.name | string | A numerical name"
    test_java_bad $testfile "[Test Group Fail"
    test_java_bad $testfile "Fail Test Group]"

    rm $testfile
}

workingConfig=`mktemp -t test`
createWorkingConfig $workingConfig
test_java_working $workingConfig
test_python_working $workingConfig

test_java_not_working


# Clean up
rm $workingConfig
