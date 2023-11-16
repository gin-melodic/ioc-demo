package main

import (
	"flag"
	"fmt"
	"gopkg.in/yaml.v3"
	"ioc-script/res"
	"log"
	"os"
	"strings"
	"time"
)

type ConfigModule struct {
	BaseURL  string `yaml:"baseURL"`
	Services []struct {
		Name        string `yaml:"name"`
		Path        string `yaml:"path"`
		Description string `yaml:"description"`
		Bypass      bool   `yaml:"bypass,omitempty"`
	}
}

func main() {
	c, outPath, err := parseFlag()
	if err != nil {
		log.Fatalf("parse flag error. %s", err)
	}

	if err := renderTemplate(c, outPath); err != nil {
		log.Fatalf("render template error. %s", err)
	}
	log.Printf("\ngenerate %s success.\n", outPath)
}

func parseFlag() (*ConfigModule, string, error) {
	// get config file
	configPath := flag.String("c", "./config.yml", "config.yml relative path")
	if configPath == nil {
		return nil, "", fmt.Errorf("flag parse error, pls pass config.yml relative path with -c")
	}

	// set output swift file path
	outPath := flag.String("o", "./network/Services.swift", "")
	if outPath == nil {
		return nil, "", fmt.Errorf("flag parse error, pls pass out swift file relative path with -o")
	}
	flag.Parse()

	// check config file
	if _, err := os.Stat(*configPath); err != nil {
		return nil, "", fmt.Errorf("parse %s error. %s", *configPath, err)
	}

	// read config file
	yamlFile, err := os.ReadFile(*configPath)
	if err != nil {
		return nil, "", fmt.Errorf("parse yaml file %s error. %s", *configPath, err)
	}

	var c ConfigModule
	if err := yaml.Unmarshal(yamlFile, &c); err != nil {
		return nil, "", fmt.Errorf("unmarshal yaml file content error. %s\n %s", err, string(yamlFile))
	}

	return &c, *outPath, nil
}

func renderTemplate(config *ConfigModule, out string) error {
	tc := res.Template
	timeSlot := "#CREATE_TIME#"
	contentSlot := "#CONTENT#"
	now := time.Now().Format("2006/01/02 15:04:05")
	tc = strings.Replace(tc, timeSlot, now, -1)

	var content string
	for _, serv := range config.Services {
		if serv.Description != "" {
			content += "\t/// " + serv.Description + "\n"
		} else {
			content += "\n"
		}
		content += fmt.Sprintf("\tcase %s = \"%s\"\n", capitalize(serv.Name), serv.Name)
	}

	tc = strings.Replace(tc, contentSlot, content, -1)

	if err := os.WriteFile(out, []byte(tc), 0755); err != nil {
		return fmt.Errorf("write file %s error. %s", out, err)
	}
	return nil
}

func capitalize(str string) string {
	var upperStr string
	vv := []rune(str)
	for i := 0; i < len(vv); i++ {
		if i == 0 {
			if vv[i] >= 97 && vv[i] <= 122 {
				vv[i] -= 32
				upperStr += string(vv[i])
			} else {
				return str
			}
		} else {
			upperStr += string(vv[i])
		}
	}
	return upperStr
}
